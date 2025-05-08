open Ctypes
open Pjrt_base.Type_description

module Types (F : Cstubs.Types.TYPE) = struct
  open Pjrt_base.Type_description.Base (F)
  open F

  let client : [ `Client ] structure typ = snd @@ make_struct_base "Client"
  let device : [ `Device ] structure typ = snd @@ make_struct_base "Device"
  let memory : [ `Memory ] structure typ = snd @@ make_struct_base "Memory"
  let shapeSpec : [ `ShapeSpec ] structure typ = snd @@ make_struct_base "ShapeSpec"
  let deviceDescription : [ `DeviceDescription ] structure typ = snd @@ make_struct_base "DeviceDescription"
  let topologyDescription : [ `TopologyDescription ] structure typ = snd @@ make_struct_base "TopologyDescription"
  let executable : [ `Executable ] structure typ = snd @@ make_struct_base "Executable"
  let loadedExecutable : [ `LoadedExecutable ] structure typ = snd @@ make_struct_base "LoadedExecutable"
  let buffer : [ `Buffer ] structure typ = snd @@ make_struct_base "Buffer"

  let asyncHostToDeviceTransferManager : [ `AsyncHostToDeviceTransferManager ] structure typ =
    snd @@ make_struct_base "AsyncHostToDeviceTransferManager"

  (* A callback to delete the value returned by PJRT_KeyValueGetCallback.  *)
  let keyValueGetCallback_ValueDeleter =
    typedef (static_funptr (ptr char @-> returning void)) @@ _NS "KeyValueGetCallback_ValueDeleter"

  module KeyValueTryGetCallback = struct
    module Args = struct
      type t

      let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Event_IsReady_Args"
      let key = field t "key" string
      let key_size = field t "key_size" size_t
      let user_arg = field t "user_arg" @@ ptr void
      let callback_error = field t "callback_error" @@ ptr callbackError
      let value_ = field t "value" @@ ptr char (* out *)
      let value_size = field t "value_size" size_t (* out *)
      let value_deleter_callback = field t "value_deleter_callback;" keyValueGetCallback_ValueDeleter
      let () = seal t
    end

    (* Returns true if this PJRT_Event has completed, including if an error has
       occurred. *)
    let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "KeyValueTryGetCallback"
  end
end
