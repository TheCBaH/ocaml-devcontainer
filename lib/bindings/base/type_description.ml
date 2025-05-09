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

  let make_struct_traits name =
    let name, t = make_struct_base name in
    let size = constant (name ^ "_STRUCT_SIZE") size_t in
    (name, size, t)

  let make_struct name =
    let name, size, t = make_struct_traits name in
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
  let copyToDeviceStream : [ `CopyToDeviceStream ] structure typ = snd @@ make_struct_base "CopyToDeviceStream"
  let bufferMemoryLayout : [ `BufferMemoryLayout ] structure typ = snd @@ make_struct_base "Buffer_MemoryLayout"
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
    typedef
      (static_funptr (errorCode (* code *) @-> string (* message *) @-> size_t (* message_size *) @-> returning error))
    @@ ns "CallbackError"

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
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning void)) @@ _NS "Error_Destroy"
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
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning void)) @@ _NS "Error_Message"
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

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Error_GetCode"
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
