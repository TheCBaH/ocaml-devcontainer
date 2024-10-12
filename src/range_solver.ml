
module Id = struct
  type t = int
  let compare = Int.compare
end

module PriorityId = struct
  type t = {
    id : Id.t;
    size: int;
  }
  let compare a b =
    match Int.compare a.size b.size with
    | 0 -> Int.compare a.id b.id
    | n -> n
end

module MapPriorityId = Map.Make(PriorityId)

module SetId = Set.Make(Id)

module MapId = Map.Make(Id)

let size = 100
let sizes = [
  0,10;
  1,10;
  2,10;
  3,10;
  4,10;
  5,10;
  6,10;
  7,10;
  8,10;
  9,10;
  11,20;
  12,30;
] |> List.to_seq |> MapId.of_seq

let groups = [
  [1;2;3;4;5;6;7;8;9;10];
  [1;3;4;5;6;7;8;9;10;11];
  [3;5;6;8;10;11;12];
]

let dependencies =
  List.fold_left (fun m l ->
    let s = SetId.of_list l in
    List.fold_left (fun m id ->
      let s = SetId.remove id s in
      MapId.update id (function
      | Some s' -> Some (SetId.union s s')
      | None -> Some s
      ) m
    ) m l
  ) MapId.empty groups

module Range = struct
  type t = int
end

let _ = MapPriorityId.find_first

let _ = SetId.find_first_opt