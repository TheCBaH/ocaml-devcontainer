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

  module Extension_Base = struct
    type t

    let struct_size, size, (t : t structure typ) = make_struct "Extension_Base"
    let type_ = field t "type" extension_type
    let next = field t "next" @@ ptr t
    let () = seal t
  end

  module Version = struct
    let major = constant (_NS "API_MAJOR") int
    let minor = constant (_NS "API_MINOR") int

    type t

    let struct_size, size, (t : t structure typ) = make_struct "Api_Version"
    let extension_start = field t "extension_start" @@ ptr Extension_Base.t
    let major_version = field t "major_version" int
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
