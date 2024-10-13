module Id = struct
  type t = int

  let compare = Int.compare
end

module PriorityId = struct
  type t = { id : Id.t; size : int }

  let compare a b = match Int.compare a.size b.size with 0 -> Int.compare a.id b.id | n -> n
end

module MapPriorityId = Map.Make (PriorityId)
module SetId = Set.Make (Id)
module MapId = Map.Make (Id)

let size = 100

let sizes =
  [ (1, 10); (2, 10); (3, 10); (4, 10); (5, 10); (6, 10); (7, 10); (8, 10); (9, 10); (11, 20); (12, 30) ]
  |> List.to_seq |> MapId.of_seq

let groups = [ [ 1; 2; 3; 4; 5; 6; 7; 8; 9; 10 ]; [ 1; 3; 5; 6; 7; 8; 9; 10; 11 ]; [ 3; 5; 6; 8; 10; 11; 12 ] ]

let dependencies =
  List.fold_left
    (fun m l ->
      let s = SetId.of_list l in
      List.fold_left
        (fun m id ->
          let s = SetId.remove id s in
          MapId.update id (function Some s' -> Some (SetId.union s s') | None -> Some s) m)
        m l)
    MapId.empty groups

module Range = struct
  type r = { b : int; e : int }
  type t = r list

  let empty = []

  let singleton ?e ~b () =
    let e = Option.value ~default:(succ b) e in
    assert (b < e);
    [ { b; e } ]

  let length_single ~size r =
    assert (r.e > r.b);
    assert (r.e >= r.b + size);
    1 + r.e + -(r.b + size)

  let length ~size t =
    List.fold_left
      (fun l r ->
        assert (r.e > r.b);
        assert (r.e >= r.b + size);
        l + length_single ~size r)
      0 t

  let to_seq ~size t =
    let rec seq_ranges l () = match l with r :: tl -> seq_range tl r.b (length_single ~size r) () | [] -> Seq.Nil
    and seq_range l off left () =
      assert (left >= 0);
      let next = if left = 0 then seq_ranges l else seq_range l (succ off) (pred left) in
      Seq.Cons (off, next)
    in
    seq_ranges t

  let remove ?e ~b ~size t =
    let e' = Option.value ~default:(succ b) e in
    let b' = b in
    assert (b' <= e');
    let add size r l =
      assert (r.b <= r.e);
      if r.b + size <= r.e then r :: l else l
    in
    let finalize tl hd = List.rev_append tl hd |> List.rev in
    let rec remove_aux dirty a l =
      match l with
      | [] -> if dirty then List.rev a else t
      | ({ b; e } as hd) :: tl ->
          if e' <= b then (* b'--e'--b++e *)
            if dirty then finalize l a else t
          else if e <= b' then (
            (* b++e..b'--e' *)
            assert (not dirty);
            remove_aux false (hd :: a) tl)
          else if (* b' .. e | b .. e'  *)
                  b <= b' then
            if e <= e' then (* b++b'-e.e' *)
              remove_aux true (add size { b; e = b' } a) tl
            else (* b++b'.e'+e *)
              finalize tl (add size { b = e'; e } (add size { b; e = b' } a))
          else if e <= e' then (* b'--b++e-e' *)
            remove_aux true a tl
          else (* b'--b--e'+e *)
            finalize tl (add size { b = e'; e } a)
    in
    remove_aux false [] t
end

let x = Range.singleton ~b:70 ~e:120 ()
let x = Range.remove ~size:10 ~b:90 x
let x = Range.remove ~size:10 ~b:100 x
let _ = Range.remove ~size:10 ~b:90 ~e:100 x
let _ = Range.remove ~size:10 ~b:85 ~e:105 x
let _ = Range.singleton ~b:70 ~e:80 () |> Range.length ~size:10
let _ = Range.singleton ~b:70 ~e:80 () |> Range.length ~size:1
let _ = Range.singleton ~b:0 ~e:100 () |> Range.remove ~size:10 ~b:10 ~e:70
let _ = Range.to_seq ~size:10 x |> List.of_seq
let _ = Range.singleton ~b:30 ~e:100 () |> Range.to_seq ~size:20 |> List.of_seq
let _ = Range.singleton ~b:0 ~e:100 () |> Range.remove ~size:10 ~b:10 ~e:70 |> Range.to_seq ~size:10 |> List.of_seq

let base =
  MapId.fold
    (fun id s m ->
      let b = 0 in
      let r = Range.singleton ~b ~e:size () in
      let m = MapPriorityId.add PriorityId.{ id; size = Range.length ~size:s r } r m in
      m)
    sizes MapPriorityId.empty

let _ = MapPriorityId.min_binding base

let advance ~b ~e deps base =
  MapPriorityId.fold
    (fun pid r next ->
      if SetId.mem pid.id deps then
        let size = MapId.find pid.id sizes in
        let r = Range.remove ~size ~b ~e r in
        let pid = PriorityId.{ pid with size = Range.length ~size r } in
        MapPriorityId.add pid r next
      else MapPriorityId.add pid r next)
    base MapPriorityId.empty

let get_best ~size seq dependencies base =
  let deps =
    MapPriorityId.fold (fun pid r deps -> if SetId.mem pid.id dependencies then (pid.id, r) :: deps else deps) base []
  in
  let rank ~b ~e =
    List.fold_left
      (fun rl (id, r) ->
        let size = MapId.find id sizes in
        let r = Range.remove ~size ~b ~e r in
        let rank = Range.length ~size r in
        (id, rank, r) :: rl)
      [] deps
  in
  let rank_sum rl =
    List.fold_left
      (fun (sum, l) r ->
        let _, rank, _ = r in
        (sum + rank, r :: l))
      (0, []) rl
  in
  let candidates =
    Seq.fold_left
      (fun l b ->
        let rank = rank ~b ~e:(b + size) |> rank_sum in
        (b, rank) :: l)
      [] seq
  in
  let a_candidates = Array.of_list candidates in
  Array.sort (fun (_, (a, _)) (_, (b, _)) -> Int.compare b a) a_candidates;
  Array.to_list a_candidates |> ignore;
  candidates

let make_next base =
  let pid, min = MapPriorityId.min_binding base in
  let size = MapId.find pid.id sizes in
  let seq = Range.to_seq ~size min in
  let deps = MapId.find pid.id dependencies in
  let b = get_best ~size seq deps base |> List.hd |> fst in
  MapPriorityId.remove pid base |> advance ~b ~e:(b + size) deps

let show_best base =
  let pid, min = MapPriorityId.min_binding base in
  let size = MapId.find pid.id sizes in
  let seq = Range.to_seq ~size min in
  let deps = MapId.find pid.id dependencies in
  get_best ~size seq deps base

let next = base
let _ = show_best next
let next = make_next next
let _ = MapPriorityId.min_binding next
let next = make_next next
let _ = MapPriorityId.min_binding next
let _ = MapPriorityId.bindings next
