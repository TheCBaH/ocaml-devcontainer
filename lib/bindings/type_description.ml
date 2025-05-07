open Ctypes

module Types (F : Cstubs.Types.TYPE) = struct
  open F

  let ns name = "pjrt_" ^ name
  let _NS name = "PJRT_" ^ name

  let make_enum name values =
    let _NAME v = _NS @@ name ^ "_" ^ v in
    enum ~typedef:true (_NS name) @@ List.map (fun (t, name) -> (t, constant (_NAME name) int64_t)) values

  (* ------------------------------- Extensions ---------------------------------- *)
  let extension_type = make_enum "Extension_Type" Types.Extension_Type.values

  let make_struct name =
    let name = _NS name in
    let t = structure name in
    let size = constant (name ^ "_STRUCT_SIZE") size_t in
    let struct_size = field t "struct_size" size_t in
    (struct_size, size, t)

  (* PJRT_Extension_Base contains a type and a pointer to next
     PJRT_Extension_Base. The framework can go through this chain to find an
     extension and identify it with the type. *)
  module Extension_Base = struct
    type t

    let struct_size, size, (t : t structure typ) = make_struct "Extension_Base"
    let type_ = field t "type" extension_type
    let next = field t "next" @@ ptr t
    let () = seal t
  end

  (* ------------------------------- Version ---------------------------------- *)
  module Version = struct
    (* Incremented when an ABI-incompatible change is made to the interface.
       Changes include:
       * Deleting a method or argument
       * Changing the type of an argument
       * Rearranging fields in the PJRT_Api or argument structs *)
    let major = constant (_NS "API_MAJOR") int

    (* Incremented when the interface is updated in a way that is potentially
       ABI-compatible with older versions, if supported by the caller and/or
       implementation.

       Callers can implement forwards compatibility by using PJRT_Api_Version to
       check if the implementation is aware of newer interface additions.

       Implementations can implement backwards compatibility by using the
       `struct_size` fields to detect how many struct fields the caller is aware of.

       Changes include:
       * Adding a new field to the PJRT_Api or argument structs
       * Renaming a method or argument (doesn't affect ABI) *)
    let minor = constant (_NS "API_MINOR") int

    type t

    let struct_size, size, (t : t structure typ) = make_struct "Api_Version"
    let extension_start = field t "extension_start" @@ ptr Extension_Base.t

    (* out *)
    let major_version = field t "major_version" int

    (* out *)
    let minor_version = field t "minor_version" int
    let () = seal t
  end

  module Api = struct
    type t

    let _struct : t structure typ = F.structure @@ _NS "Api"
    let t = ptr @@ const _struct
  end

  let init = typedef (static_funptr (void @-> returning Api.t)) @@ ns "init"

  module Dl = struct
    type t

    let t : t structure typ = structure (ns "t")
    let handle = field t "handle" (ptr void)
    let init = field t "init" init
    let () = seal t
  end
end
