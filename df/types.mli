module UInt : sig
  type 'a t

  val of_int : int -> 'a t
  val to_int : 'a t -> int
  val ( + ) : 'a t -> 'a t -> 'a t
  val pp : Format.formatter -> 'a t -> unit
  val compare : 'a t -> 'a t -> int
end

module Uid : sig
  type tag
  type t = tag UInt.t

  val compare : t -> t -> int
end

type uid = Uid.t

val uid_of_int : int -> uid

module Inode : sig
  type tag
  type t = tag UInt.t

  val compare : t -> t -> int
end

type inode = Inode.t

val inode_of_int : int -> inode

type dev_tag
type dev = dev_tag UInt.t

val dev_of_int : int -> dev

module Size : sig
  type tag
  type t = tag UInt.t

  val of_int : scale:int -> int -> t
  val to_int : scale:int -> t -> int
end
