open Ctypes
open Pjrt_base.Type_description

module Types (F : Cstubs.Types.TYPE) = struct
  open F
  open Pjrt_base.Type_description.Base (F)

  (* ---------------------------------- Plugin ----------------------------------- *)
  module Plugin = struct
    module Initialize = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Plugin_Initialize_Args"
        let () = seal t
      end

      (* One-time plugin setup. Must be called before any other functions are called. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Plugin_Initialize"
    end

    module Attributes = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Plugin_Attributes_Args"

        (* Returned attributes have the lifetime of the process. *)
        let attributes = field t "attributes" @@ ptr @@ const namedValue (* out *)
        let num_attributes = field t "num_attributes" size_t (* out *)
        let () = seal t
      end

      (* Returns an array of plugin attributes which are key-value pairs. Common keys
       include `xla_version`, `stablehlo_current_version`, and
       `stablehlo_minimum_version`. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Plugin_Attributes"
    end
  end

  include Type_description_events.Types (F)

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
