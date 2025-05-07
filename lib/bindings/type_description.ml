open Ctypes

module Types (F : Cstubs.Types.TYPE) = struct
  open F

  let ns name = "pjrt_" ^ name
  let _NS name = "PJRT_" ^ name

  let make_enum name values =
    let _NAME v = _NS @@ name ^ "_" ^ v in
    enum ~typedef:true (_NS name) @@ List.map (fun (t, name) -> (t, constant (_NAME name) int64_t)) values

  let extension = make_enum "Extension_Type" Types.Extension_Type.values

  module Api = struct
    type t

    let _struct : t structure typ = F.structure @@ _NS "Api"
    let t = ptr @@ const _struct
  end

  let init = typedef (static_funptr (void @-> returning Api.t)) @@ ns "init"

  module Dl = struct
    let t : [ `pjrt_t ] structure typ = structure (ns "t")
    let handle = field t "handle" (ptr void)
    let init = field t "init" init
    let () = seal t
  end
end
