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
end
