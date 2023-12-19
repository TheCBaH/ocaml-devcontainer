type bar = { a : int }
type t = Bar of bar | Foo of int

let get_value t = match t with Bar b -> b.a | Foo a -> a
let pp_bar fmt bar = Format.fprintf fmt "@[{%u}@]" bar.a

let pp fmt t =
  match t with Bar b -> Format.fprintf fmt "@[Bar@ %a@]" pp_bar b | Foo a -> Format.fprintf fmt "@[Foo@ %u@]" a
