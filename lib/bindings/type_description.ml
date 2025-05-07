open Ctypes

module Types (F : Cstubs.Types.TYPE) = struct
  open F

  let ns name = "pjrt_" ^ name
  let _NS name = "PJRT_" ^ name

  let make_enum ?suffix name values =
    let _NAME v = _NS @@ name ^ "_" ^ v in
    let typedef_name = match suffix with None -> name | Some suffix -> name ^ "_" ^ suffix in
    enum ~typedef:true (_NS typedef_name) @@ List.map (fun (t, name) -> (t, constant (_NAME name) int64_t)) values

  (* ------------------------------- Extensions ---------------------------------- *)
  let extension_type = make_enum "Extension_Type" Types.Extension_Type.values

  let make_struct name =
    let name = _NS name in
    let t = structure name in
    let size = constant (name ^ "_STRUCT_SIZE") size_t in
    let struct_size = field t "struct_size" size_t in
    (struct_size, size, typedef t name)

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

  let pjrt_struct name =
    let struct_size, size, t = make_struct name in
    let extension_start = field t "extension_start" @@ ptr Extension_Base.t in
    (extension_start, struct_size, size, t)

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

    let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Api_Version"

    (* out *)
    let major_version = field t "major_version" int

    (* out *)
    let minor_version = field t "minor_version" int
    let () = seal t
  end

  (*// ---------------------------------- Errors ----------------------------------- *)
  (* PJRT C API methods generally return a PJRT_Error*, which is nullptr if there
     is no error and set if there is. The implementation allocates any returned
     PJRT_Errors, but the caller is always responsible for freeing them via
     PJRT_Error_Destroy. *)
  module Error = struct
    type t

    let _struct : t structure typ = F.structure @@ _NS "Error"
    let error = ptr @@ typedef _struct @@ ns "Error"
    let const_error = ptr @@ const @@ typedef _struct @@ ns "Error"

    module Destroy = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Error_Destroy_Args"
        let error = field t "error" error
        let () = seal t
      end

      (* Frees `error`. `error` can be nullptr. *)
      let api = typedef (static_funptr (void @-> returning @@ ptr Args.t)) @@ _NS "Error_Destroy"
    end

    module Message = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Error_Message_Args"
        let error = field t "error" const_error

        (* Has the lifetime of `error`. *)
        let message = field t "message" string
        let message_size = field t "message_size" size_t
        let () = seal t
      end

      (* Gets the human-readable reason for `error`. `message` has the lifetime of
       `error`. *)
      let api = typedef (static_funptr (void @-> returning @@ ptr Destroy.Args.t)) @@ ns "Error_Message"
    end

    (* Codes are based on https://abseil.io/docs/cpp/guides/status-codes *)
    let code = make_enum "Error_Code" Types.Error_Code.values

    module GetCode = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Error_GetCode_Args"
        let error = field t "error" const_error

        (* out *)
        let code = field t "code" code
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Error_GetCode"
    end

    (* Function for PJRT implementation to pass to callback functions provided by
       caller so the callback can create a PJRT_Error* on error (to return to the
       implementation). `message` is only required to live for the
       PJRT_CallbackError call, i.e. the PJRT_CallbackError implementation must copy
       `message` into the PJRT_Error. *)
    let callback_error = typedef (static_funptr (code @-> string @-> size_t @-> returning error)) @@ ns "CallbackError"
  end

  let api_error = Error.error
  let namedValue = make_enum "NamedValue" ~suffix:"Type" Types.NamedValue.values

  (* Named value for key-value pairs. *)
  module NamedValue = struct
    type t

    let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "NamedValue"
    let name = field t "name" string
    let name_size = field t "name_size" size_t
    let type_ = field t "type" namedValue
    let string_value = field t "string_value" string
    let int64_value = field t "int64_value" int64_t
    let int64_array_value = field t "int64_array_value" @@ ptr int64_t
    let float_value = field t "float_value" int64_t
    let bool_value = field t "bool_value" bool

    (* `value_size` is the number of elements for array/string and 1 for scalar
       values. *)
    let value_size = field t "value_size" size_t
  end

  (* ---------------------------------- Plugin ----------------------------------- *)
  module Plugin = struct
    module Initialize = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Plugin_Initialize_Args"
        let () = seal t
      end

      (* One-time plugin setup. Must be called before any other functions are called. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning Error.error)) @@ _NS "Plugin_Initialize"
    end

    module Attributes = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Plugin_Attributes_Args"

        (* Returned attributes have the lifetime of the process. *)
        let attributes = field t "attributes" @@ ptr @@ const NamedValue.t (* out *)
        let num_attributes = field t "num_attributes" size_t (* out *)
        let () = seal t
      end

      (* Returns an array of plugin attributes which are key-value pairs. Common keys
       include `xla_version`, `stablehlo_current_version`, and
       `stablehlo_minimum_version`. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning Error.error)) @@ _NS "Plugin_Attributes"
    end
  end

  (* ---------------------------------- Events ----------------------------------- *)

  (* Represents a notifying event that is returned by PJRT APIs that enqueue
     asynchronous work, informing callers when the work is complete and reporting
     a value of type `PJRT_Error*` or `nullptr` as error status.

     Callers are always responsible for freeing `PJRT_Event`s by calling
     `PJRT_Event_Destroy`. *)
  module Event = struct
    type t

    let _struct : t structure typ = F.structure @@ _NS "Event"
    let t = ptr @@ typedef _struct @@ ns "Event"

    module Destroy = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Event_Destroy_Args"
        let event = field t "event" t
        let () = seal t
      end

      (* Frees `event`. `event` can be `nullptr`. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning Error.error)) @@ _NS "Event_Destroy"
    end

    module IsReady = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Event_IsReady_Args"
        let event = field t "event" t
        let is_ready = field t "is_ready" bool (* out *)
        let () = seal t
      end

      (* Returns true if this PJRT_Event has completed, including if an error has
       occurred. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning Error.error)) @@ _NS "Event_IsReady"
    end

    module Error = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Event_Error_Args"
        let event = field t "event" t
        let () = seal t
      end

      (* Should only be called if PJRT_Event_IsReady returns true.
       Returns `nullptr` if there is no error.
       The returned error should be freed with `PJRT_Error_Destroy`.

       If `PJRT_Event_Await` has been called, this will return a pointer to an
       identical error status as that call, as will subsequent calls to
       `PJRT_Event_Error`. However, each of these `PJRT_Error *` pointers are
       independent of `PJRT_Error *`s returned by other function calls, so they must
       each be freed separately using `PJRT_Error_Destroy`. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning Error.error)) @@ _NS "Event_Error"
    end

    module Await = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Event_Await_Args"
        let event = field t "event" t
        let () = seal t
      end

      (* Blocks the calling thread until `event` is ready, then returns the error
       status (with `nullptr` indicating no error). The returned status should be
       freed with `PJRT_Error_Destroy`. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning api_error)) @@ _NS "Event_Await"
    end

    (* A callback to be performed once an event is ready. It will be called on the
       event's error state and a pointer to an object of the caller's choice.
       Ownership of `error` is passed to the callback. The callback must destroy
       `error` via `PJRT_Error_Destroy`. The caller retains ownership of `user_arg`. *)
    let onReadyCallback =
      typedef (static_funptr (api_error @-> ptr void @-> returning void)) @@ ns "Event_OnReadyCallback"

    module OnReady_Args = struct
      type t

      let event = t
      let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Event_OnReady_Args"
      let event = field t "event" event
      let callback = field t "callback_" onReadyCallback

      (* `user_arg` allows `callback` to be called with arbitrary arguments (e.g.
         via pointers in a struct cast to void* ). *)
      let user_arg = field t "user_arg" (ptr void)
      let () = seal t
    end

    (* Registers `callback` to be called once `event` is ready, with `event`'s
       error status and a pointer to an object of the caller's choice as arguments. *)
    let onReady = typedef (static_funptr (ptr OnReady_Args.t @-> returning api_error)) @@ _NS "Event_OnReady"
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
