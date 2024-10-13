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
  [ (0, 10); (1, 10); (2, 10); (3, 10); (4, 10); (5, 10); (6, 10); (7, 10); (8, 10); (9, 10); (11, 20); (12, 30) ]
  |> List.to_seq |> MapId.of_seq

let groups = [ [ 1; 2; 3; 4; 5; 6; 7; 8; 9; 10 ]; [ 1; 3; 4; 5; 6; 7; 8; 9; 10; 11 ]; [ 3; 5; 6; 8; 10; 11; 12 ] ]

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

  let length ~size t =
    List.fold_left
      (fun l r ->
        assert (r.e > r.b);
        assert (r.e > r.b + size);
        l + (r.e - (r.b + size)))
      0 t

  let remove ?e ~b ~size t =
    let e' = Option.value ~default:(succ b) e in
    let b' = b in
    assert (b' <= e');
    let add size r l =
      assert (r.b <= r.e);
      if r.b + size < r.e then r :: l else l
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
            if e <= e' then (* b--b'+e-e' *)
              remove_aux true (add size { b = b'; e } a) tl
            else (* b++b'.e'+e *)
              finalize tl (add size { b = e'; e } (add size { b; e = b' } a))
          else if e <= e' then (* b'--b++e-e' *)
            remove_aux true a tl
          else (* b'--b--e'+e *)
            finalize tl (add size { b = e'; e } a)
    in
    remove_aux false [] t
end

let x = Range.singleton ~b:80 ~e:120 ()
let x = Range.remove ~size:10 ~b:90 x
let x = Range.remove ~size:10 ~b:100 x
let _ = Range.remove ~size:10 ~b:90 ~e:100 x
let _ = Range.remove ~size:10 ~b:85 ~e:105 x

let base =
  MapId.fold
    (fun id s m ->
      let b = 0 in
      let r = Range.singleton ~b ~e:size () in
      let m = MapPriorityId.add PriorityId.{ id; size = Range.length ~size:s r } r m in
      m)
    sizes MapPriorityId.empty

let _ = MapPriorityId.min_binding base
