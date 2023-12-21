module UInt = struct
  type 'a t = int

  let of_int t = t
  let to_int t = t
  let ( + ) = Int.add
  let pp = Format.pp_print_int
  let compare = Int.compare
end

type uid_tag
type uid = uid_tag UInt.t

let uid_of_int = UInt.of_int

module Inode = struct
  type tag
  type t = tag UInt.t

  let compare = Int.compare
end

module Uid = Inode

type inode = Inode.t

let inode_of_int = UInt.of_int

type dev_tag
type dev = dev_tag UInt.t

let dev_of_int = UInt.of_int

module Size = struct
  type tag
  type t = tag UInt.t

  let of_int ~scale t = (t + scale - 1) / scale
  let to_int ~scale t = t / scale
end
