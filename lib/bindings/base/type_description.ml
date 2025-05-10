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

  let extensionType = make_enum "Extension_Type" Types.Extension_Type.values

  (* PJRT_Extension_Base contains a type and a pointer to next
     PJRT_Extension_Base. The framework can go through this chain to find an
     extension and identify it with the type. *)
  module Extension_Base = struct
    type t = [ `Extension_Base ]

    let struct_size, size, (t : t structure typ) = make_struct "Extension_Base"
    let type_ = field t "type" extensionType
    let next = field t "next" @@ ptr t
    let () = seal t
  end

  let pjrt_struct name = pjrt_struct name

  (* Function for PJRT implementation to pass to callback functions provided by
       caller so the callback can create a PJRT_Error* on error (to return to the
       implementation). `message` is only required to live for the
       PJRT_CallbackError call, i.e. the PJRT_CallbackError implementation must copy
       `message` into the PJRT_Error. *)
  let callbackError =
    typedef
      (static_funptr
         (uint
        (* should be  errorCode *)
        (* code *) @-> string
         (* message *) @-> size_t
         (* message_size *) @-> returning error))
    @@ ns "CallbackError"
end
