open Ctypes

let ns name = "pjrt_" ^ name
let _NS name = "PJRT_" ^ name

module Base (F : Cstubs.Types.TYPE) = struct
  open F

  let make_enum ?suffix name values =
    let _NAME v = _NS @@ name ^ "_" ^ v in
    let typedef_name = match suffix with None -> name | Some suffix -> name ^ "_" ^ suffix in
    enum ~typedef:true (_NS typedef_name) @@ List.map (fun (t, name) -> (t, constant (_NAME name) int64_t)) values

  let make_struct_base name =
    let name = _NS name in
    (name, structure name)

  let make_struct name =
    let name, t = make_struct_base name in
    let size = constant (name ^ "_STRUCT_SIZE") size_t in
    let struct_size = field t "struct_size" size_t in
    (struct_size, size, typedef t name)

  let extensionBase : [ `Extension_Base ] structure typ = snd @@ make_struct_base "Extension_Base"
  let namedValue : [ `Extension_Base ] structure typ = snd @@ make_struct_base "NamedValue"
  let event : [ `Event ] structure typ = snd @@ make_struct_base "Event"

  let pjrt_struct name =
    let struct_size, size, t = make_struct name in
    let extension_start = field t "extension_start" @@ ptr extensionBase in
    (extension_start, struct_size, size, t)

  let error_struct : [ `Error ] structure typ = F.structure @@ _NS "Error"
  let error = ptr @@ typedef error_struct @@ ns "Error"
  let const_error = ptr @@ const @@ typedef error_struct @@ ns "Error"
  let callbackError = ptr void (* forward declaration for proper callbackError from Types *)
  let client : [ `Client ] structure typ = snd @@ make_struct_base "Client"
  let device : [ `Device ] structure typ = snd @@ make_struct_base "Device"
  let memory : [ `Memory ] structure typ = snd @@ make_struct_base "Memory"
  let shapeSpec : [ `ShapeSpec ] structure typ = snd @@ make_struct_base "ShapeSpec"
  let deviceDescription : [ `DeviceDescription ] structure typ = snd @@ make_struct_base "DeviceDescription"
  let topologyDescription : [ `TopologyDescription ] structure typ = snd @@ make_struct_base "TopologyDescription"
  let executable : [ `Executable ] structure typ = snd @@ make_struct_base "Executable"
  let loadedExecutable : [ `LoadedExecutable ] structure typ = snd @@ make_struct_base "LoadedExecutable"
  let buffer : [ `Buffer ] structure typ = snd @@ make_struct_base "Buffer"
  let executeContext : [ `ExecuteContext ] structure typ = snd @@ make_struct_base "ExecuteContext"
  let program : [ `Program ] structure typ = snd @@ make_struct_base "Program"

  (*
  let chunk_deleter_fun = static_funptr (ptr void @-> ptr void @-> returning void)

  module Chunk_fields = struct
    type t

    let t : t structure typ = structure (_NS "Chunk")
    let data = field t "data" (ptr void)
    let size = field t "size" size_t
    let deleter = field t "deleter" chunk_deleter_fun
    let deleter_arg = field t "deleter_arg" (ptr void)
    let () = seal t
  end

  let chunk : Chunk_fields.t_struct structure typ = Chunk_fields.t
  let copyToDeviceStream : [ `CopyToDeviceStream ] structure typ = snd @@ make_struct_base "CopyToDeviceStream"

  let sendCallback =
    typedef
      (static_funptr (ptr chunk @-> ptr callbackError @-> size_t @-> bool @-> ptr void @-> returning error))
      (_NS "SendCallback")

  let recvCallback =
    typedef (static_funptr (ptr copyToDeviceStream @-> ptr void @-> returning void)) (_NS "RecvCallback")

  module SendCallbackInfo_fields = struct
    type t_struct

    let t : t_struct structure typ = structure (_NS "SendCallbackInfo")

    (* This struct is defined with PJRT_DEFINE_STRUCT_TRAITS, so _STRUCT_SIZE is available,
       but struct_size is not an actual field in the C struct.
       Cstubs will still need the _STRUCT_SIZE constant. We ensure it's declared
       by calling make_struct_base, but we only use the resulting type 't'.
       The s_size_const from make_struct would be PJRT_SendCallbackInfo_STRUCT_SIZE. *)
    let _ = make_struct_base "SendCallbackInfo" (* Ensures _STRUCT_SIZE is known by Cstubs *)
    let channel_id = field t "channel_id" int64_t
    let user_arg = field t "user_arg" (ptr void)
    let send_callback = field t "send_callback" sendCallback
    let () = seal t
  end

  let sendCallbackInfo : SendCallbackInfo_fields.t_struct structure typ = SendCallbackInfo_fields.t

  module RecvCallbackInfo_fields = struct
    type t_struct

    let t : t_struct structure typ = structure (_NS "RecvCallbackInfo")
    let _ = make_struct_base "RecvCallbackInfo" (* Ensures _STRUCT_SIZE is known by Cstubs *)
    let channel_id = field t "channel_id" int64_t
    let user_arg = field t "user_arg" (ptr void)
    let recv_callback = field t "recv_callback" recvCallback
    let () = seal t
  end

  let recvCallbackInfo : RecvCallbackInfo_fields.t_struct structure typ = RecvCallbackInfo_fields.t

  module ExecuteOptions_fields = struct
    type t_struct

    let s_extension_start, s_struct_size, s_size_const, (struct_typ : t_struct structure typ) =
      pjrt_struct "ExecuteOptions"

    let send_callbacks = field struct_typ "send_callbacks" (ptr (ptr sendCallbackInfo))
    let recv_callbacks = field struct_typ "recv_callbacks" (ptr (ptr recvCallbackInfo))
    let num_send_ops = field struct_typ "num_send_ops" size_t
    let num_recv_ops = field struct_typ "num_recv_ops" size_t
    let launch_id = field struct_typ "launch_id" int
    let non_donatable_input_indices = field struct_typ "non_donatable_input_indices" (ptr (const int64_t))
    let num_non_donatable_input_indices = field struct_typ "num_non_donatable_input_indices" size_t
    let context = field struct_typ "context" (ptr executeContext)
    let () = seal struct_typ
  end

  let executeOptions : ExecuteOptions_fields.t_struct structure typ = ExecuteOptions_fields.struct_typ
  let serializedExecutable : [ `SerializedExecutable ] structure typ = snd @@ make_struct_base "SerializedExecutable"
  let serialized_executable_deleter_fun = static_funptr (ptr serializedExecutable @-> returning void)
*)
end

module Types (F : Cstubs.Types.TYPE) = struct
  open F
  open Base (F)

  (* ------------------------------- Extensions ---------------------------------- *)

  let extension_type = make_enum "Extension_Type" Types.Extension_Type.values
  let bufferType = make_enum "Buffer_Type" Types.Buffer_Type.values

  (* PJRT_Extension_Base contains a type and a pointer to next
     PJRT_Extension_Base. The framework can go through this chain to find an
     extension and identify it with the type. *)
  module Extension_Base = struct
    type t = [ `Extension_Base ]

    let struct_size, size, (t : t structure typ) = make_struct "Extension_Base"
    let type_ = field t "type" extension_type
    let next = field t "next" @@ ptr t
    let () = seal t
  end

  let pjrt_struct name = pjrt_struct name

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

  let errorCode = make_enum "Error_Code" Types.Error_Code.values

  (* Function for PJRT implementation to pass to callback functions provided by
       caller so the callback can create a PJRT_Error* on error (to return to the
       implementation). `message` is only required to live for the
       PJRT_CallbackError call, i.e. the PJRT_CallbackError implementation must copy
       `message` into the PJRT_Error. *)
  let callbackError =
    typedef (static_funptr (errorCode @-> string @-> size_t @-> returning error)) @@ ns "CallbackError"

  (*// ---------------------------------- Errors ----------------------------------- *)
  (* PJRT C API methods generally return a PJRT_Error*, which is nullptr if there
     is no error and set if there is. The implementation allocates any returned
     PJRT_Errors, but the caller is always responsible for freeing them via
     PJRT_Error_Destroy. *)
  module Error = struct
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

    module GetCode = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Error_GetCode_Args"
        let error = field t "error" const_error

        (* out *)
        let code = field t "code" errorCode
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Error_GetCode"
    end
  end

  let api_error = error
  let namedValue = make_enum "NamedValue" ~suffix:"Type" Types.NamedValue.values

  (* Named value for key-value pairs. *)
  module NamedValue = struct
    type t = [ `NamedValue ]

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
end
