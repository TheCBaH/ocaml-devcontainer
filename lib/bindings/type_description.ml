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
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Plugin_Initialize"
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
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Plugin_Attributes"
    end
  end

  include Type_description_buffer.Types (F)
  include Type_description_client.Types (F)
  include Type_description_device.Types (F)
  include Type_description_events.Types (F)

  (* ------------------------------- Version ---------------------------------- *)
  (* The plugin should set the major_version and minor_version of
     PJRT_Api.pjrt_api_version to be the `PJRT_API_MAJOR` and `PJRT_API_MINOR` in
     this header that the implementation was compiled with. *)
  module Version = struct
    (* PJRT_API_MAJOR: Incremented when an ABI-incompatible change is made to the interface.
       Changes include:
       * Deleting a method or argument
       * Changing the type of an argument
       * Rearranging fields in the PJRT_Api or argument structs *)
    let major = constant (_NS "API_MAJOR") int

    (* PJRT_API_MINOR: Incremented when the interface is updated in a way that is potentially
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

    type t (* Corresponds to PJRT_Api_Version struct *)

    let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Api_Version"
    let major_version = field t "major_version" int (* out *)
    let minor_version = field t "minor_version" int (* out *)
    let () = seal t
  end

  let errorCode = make_enum "Error_Code" Pjrt_base.Types.Error_Code.values

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
  let namedValue = make_enum "NamedValue" ~suffix:"Type" Pjrt_base.Types.NamedValue.values

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
    let () = seal t
  end

  module Api = struct
    type t

    let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Api"
    let api_version_field = field t "pjrt_api_version" Version.t
    let errorDestroy = field t "PJRT_Error_Destroy" Error.Destroy.api
    let errorMessage = field t "PJRT_Error_Message" Error.Message.api
    let errorGetCode = field t "PJRT_Error_GetCode" Error.GetCode.api
    let pluginInitialize = field t "PJRT_Plugin_Initialize" Plugin.Initialize.api
    let pluginAttributes = field t "PJRT_Plugin_Attributes" Plugin.Attributes.api
    let eventDestroy = field t "PJRT_Event_Destroy" Event.Destroy.api
    let eventIsReady = field t "PJRT_Event_IsReady" Event.IsReady.api
    let eventError = field t "PJRT_Event_Error" Event.Error.api
    let eventAwait = field t "PJRT_Event_Await" Event.Await.api
    let eventOnReady = field t "PJRT_Event_OnReady" Event.OnReady.api
    let clientCreate = field t "PJRT_Client_Create" Client.Create.api
    let clientDestroy = field t "PJRT_Client_Destroy" Client.Destroy.api
    let clientPlatformName = field t "PJRT_Client_PlatformName" Client.PlatformName.api
    let clientProcessIndex = field t "PJRT_Client_ProcessIndex" Client.ProcessIndex.api
    let clientPlatformVersion = field t "PJRT_Client_PlatformVersion" Client.PlatformVersion.api
    let clientDevices = field t "PJRT_Client_Devices" Client.Devices.api
    let clientAddressableDevices = field t "PJRT_Client_AddressableDevices" Client.AddressableDevices.api
    let clientLookupDevice = field t "PJRT_Client_LookupDevice" Client.LookupDevice.api
    let clientLookupAddressableDevice = field t "PJRT_Client_LookupAddressableDevice" Client.LookupAddressableDevice.api
    let clientAddressableMemories = field t "PJRT_Client_AddressableMemories" Client.AddressableMemories.api
    let clientCompile = field t "PJRT_Client_Compile" Client.Compile.api
    let clientDefaultDeviceAssignment = field t "PJRT_Client_DefaultDeviceAssignment" Client.DefaultDeviceAssignment.api
    let clientBufferFromHostBuffer = field t "PJRT_Client_BufferFromHostBuffer" BufferFromHostBuffer.api
    let deviceDescriptionId = field t "PJRT_DeviceDescription_Id" DeviceDescription.Id.api
    let deviceDescriptionProcessIndex = field t "PJRT_DeviceDescription_ProcessIndex" DeviceDescription.ProcessIndex.api
    let deviceDescriptionAttributes = field t "PJRT_DeviceDescription_Attributes" DeviceDescription.Attributes.api
    let deviceDescriptionKind = field t "PJRT_DeviceDescription_Kind" DeviceDescription.Kind.api
    let deviceDescriptionDebugString = field t "PJRT_DeviceDescription_DebugString" DeviceDescription.DebugString.api
    let deviceDescriptionToString = field t "PJRT_DeviceDescription_ToString" DeviceDescription.ToString.api
    let deviceGetDescription = field t "PJRT_Device_GetDescription" Device.GetDescription.api
    let deviceIsAddressable = field t "PJRT_Device_IsAddressable" Device.IsAddressable.api
    let deviceLocalHardwareId = field t "PJRT_Device_LocalHardwareId" Device.LocalHardwareId.api
    let deviceAddressableMemories = field t "PJRT_Device_AddressableMemories" Device.AddressableMemories.api
    let deviceDefaultMemory = field t "PJRT_Device_DefaultMemory" Device.DefaultMemory.api
    let deviceMemoryStats = field t "PJRT_Device_MemoryStats" Device.MemoryStats.api
    let memoryId = field t "PJRT_Memory_Id" Memory.Id.api
    let memoryKind = field t "PJRT_Memory_Kind" Memory.Kind.api
    let memoryDebugString = field t "PJRT_Memory_DebugString" Memory.DebugString.api
    let memoryToString = field t "PJRT_Memory_ToString" Memory.ToString.api
    let memoryAddressableByDevices = field t "PJRT_Memory_AddressableByDevices" Memory.AddressableByDevices.api
    let executableDestroy = field t "PJRT_Executable_Destroy" Executable.Destroy.api
    let executableName = field t "PJRT_Executable_Name" Executable.Name.api
    let executableNumReplicas = field t "PJRT_Executable_NumReplicas" Executable.NumReplicas.api
    let executableNumPartitions = field t "PJRT_Executable_NumPartitions" Executable.NumPartitions.api
    let executableNumOutputs = field t "PJRT_Executable_NumOutputs" Executable.NumOutputs.api

    let executableSizeOfGeneratedCodeInBytes =
      field t "PJRT_Executable_SizeOfGeneratedCodeInBytes" Executable.SizeOfGeneratedCodeInBytes.api

    let executableGetCostAnalysis = field t "PJRT_Executable_GetCostAnalysis" Executable.GetCostAnalysis.api
    let executableOutputMemoryKinds = field t "PJRT_Executable_OutputMemoryKinds" Executable.OutputMemoryKinds.api
    let executableOptimizedProgram = field t "PJRT_Executable_OptimizedProgram" Executable.OptimizedProgram.api
    let executableSerialize = field t "PJRT_Executable_Serialize" Executable.Serialize.api
    let loadedExecutableDestroy = field t "PJRT_LoadedExecutable_Destroy" LoadedExecutable.Destroy.api
    let loadedExecutableGetExecutable = field t "PJRT_LoadedExecutable_GetExecutable" LoadedExecutable.GetExecutable.api

    let loadedExecutableAddressableDevices =
      field t "PJRT_LoadedExecutable_AddressableDevices" LoadedExecutable.AddressableDevices.api

    let loadedExecutableDelete = field t "PJRT_LoadedExecutable_Delete" LoadedExecutable.Delete.api
    let loadedExecutableIsDeleted = field t "PJRT_LoadedExecutable_IsDeleted" LoadedExecutable.IsDeleted.api
    let loadedExecutableExecute = field t "PJRT_LoadedExecutable_Execute" LoadedExecutable.Execute.api
    let executableDeserializeAndLoad = field t "PJRT_Executable_DeserializeAndLoad" Executable.DeserializeAndLoad.api
    let loadedExecutableFingerprint = field t "PJRT_LoadedExecutable_Fingerprint" LoadedExecutable.Fingerprint.api
    let bufferDestroy = field t "PJRT_Buffer_Destroy" Buffer.Destroy.api
    let bufferElementType = field t "PJRT_Buffer_ElementType" Buffer.ElementType.api
    let bufferDimensions = field t "PJRT_Buffer_Dimensions" Buffer.Dimensions.api
    let bufferUnpaddedDimensions = field t "PJRT_Buffer_UnpaddedDimensions" Buffer.UnpaddedDimensions.api
    let bufferDynamicDimensionIndices = field t "PJRT_Buffer_DynamicDimensionIndices" Buffer.DynamicDimensionIndices.api
    let bufferGetMemoryLayout = field t "PJRT_Buffer_GetMemoryLayout" Buffer.GetMemoryLayout.api
    let bufferOnDeviceSizeInBytes = field t "PJRT_Buffer_OnDeviceSizeInBytes" Buffer.OnDeviceSizeInBytes.api
    let bufferDevice = field t "PJRT_Buffer_Device" Buffer.Device.api
    let bufferMemory = field t "PJRT_Buffer_Memory" Buffer.Memory.api
    let bufferDelete = field t "PJRT_Buffer_Delete" Buffer.Delete.api
    let bufferIsDeleted = field t "PJRT_Buffer_IsDeleted" Buffer.IsDeleted.api
    let bufferCopyToDevice = field t "PJRT_Buffer_CopyToDevice" Buffer.CopyToDevice.api
    let bufferToHostBuffer = field t "PJRT_Buffer_ToHostBuffer" Buffer.ToHostBuffer.api
    let bufferIsOnCpu = field t "PJRT_Buffer_IsOnCpu" Buffer.IsOnCpu.api
    let bufferReadyEvent = field t "PJRT_Buffer_ReadyEvent" Buffer.ReadyEvent.api
    let bufferUnsafePointer = field t "PJRT_Buffer_UnsafePointer" Buffer.UnsafePointer.api

    let bufferIncreaseExternalReferenceCount =
      field t "PJRT_Buffer_IncreaseExternalReferenceCount" Buffer.IncreaseExternalReferenceCount.api

    let bufferDecreaseExternalReferenceCount =
      field t "PJRT_Buffer_DecreaseExternalReferenceCount" Buffer.DecreaseExternalReferenceCount.api

    let bufferOpaqueDeviceMemoryDataPointer =
      field t "PJRT_Buffer_OpaqueDeviceMemoryDataPointer" Buffer.OpaqueDeviceMemoryDataPointer.api

    let copyToDeviceStreamDestroy = field t "PJRT_CopyToDeviceStream_Destroy" CopyDeviceStream.Destroy.api
    let copyToDeviceStreamAddChunk = field t "PJRT_CopyToDeviceStream_AddChunk" CopyDeviceStream.AddChunk.api
    let copyToDeviceStreamTotalBytes = field t "PJRT_CopyToDeviceStream_TotalBytes" CopyDeviceStream.TotalBytes.api
    let copyToDeviceStreamGranuleSize = field t "PJRT_CopyToDeviceStream_GranuleSize" CopyDeviceStream.GranuleSize.api

    let copyToDeviceStreamCurrentBytes =
      field t "PJRT_CopyToDeviceStream_CurrentBytes" CopyDeviceStream.CurrentBytes.api

    let topologyDescriptionCreate = field t "PJRT_TopologyDescription_Create" TopologyDescription.Create.api
    let topologyDescriptionDestroy = field t "PJRT_TopologyDescription_Destroy" TopologyDescription.Destroy.api

    let topologyDescriptionPlatformName =
      field t "PJRT_TopologyDescription_PlatformName" TopologyDescription.PlatformName.api

    let topologyDescriptionPlatformVersion =
      field t "PJRT_TopologyDescription_PlatformVersion" TopologyDescription.PlatformVersion.api

    let topologyDescriptionGetDeviceDescriptions =
      field t "PJRT_TopologyDescription_GetDeviceDescriptions" TopologyDescription.GetDeviceDescriptions.api

    let topologyDescriptionSerialize = field t "PJRT_TopologyDescription_Serialize" TopologyDescription.Serialize.api
    let topologyDescriptionAttributes = field t "PJRT_TopologyDescription_Attributes" TopologyDescription.Attributes.api
    let compile = field t "PJRT_Compile" Client.Compile.api
    let executableOutputElementTypes = field t "PJRT_Executable_OutputElementTypes" Executable_OutputElementTypes.api
    let executableOutputDimensions = field t "PJRT_Executable_OutputDimensions" Executable.OutputDimensions.api
    let bufferCopyToMemory = field t "PJRT_Buffer_CopyToMemory" Buffer.CopyToMemory.api

    (* Assuming Client.CreateViewOfDeviceBuffer.api is defined in type_description_client.ml *)
    let clientCreateViewOfDeviceBuffer = field t "PJRT_Client_CreateViewOfDeviceBuffer" CreateViewOfDeviceBuffer.api
    let executableFingerprint = field t "PJRT_Executable_Fingerprint" Executable.Fingerprint.api

    (* Assuming Client.TopologyDescription.api is defined in type_description_client.ml *)
    let clientTopologyDescription = field t "PJRT_Client_TopologyDescription" Client.TopologyDescription.api

    let executableGetCompiledMemoryStats =
      field t "PJRT_Executable_GetCompiledMemoryStats" Executable.GetCompiledMemoryStats.api

    let memoryKindId = field t "PJRT_Memory_Kind_Id" Memory.KindId.api
    let executeContextCreate = field t "PJRT_ExecuteContext_Create" ExecuteContext.Create.api
    let executeContextDestroy = field t "PJRT_ExecuteContext_Destroy" ExecuteContext.Destroy.api
    let bufferCopyRawToHost = field t "PJRT_Buffer_CopyRawToHost" Buffer.CopyRawToHost.api

    (* PJRT_AsyncHostToDeviceTransferManager and its functions are omitted for now,
       as their OCaml types (e.g., AsyncHostToDeviceTransferManager.Destroy.api)
       are assumed not to be defined yet. *)
    (* Assuming Client.CreateBuffersForAsyncHostToDevice.api is defined in type_description_client.ml *)
    let clientCreateBuffersForAsyncHostToDevice =
      field t "PJRT_Client_CreateBuffersForAsyncHostToDevice" Client.CreateBuffersForAsyncHostToDevice.api

    (* Assuming Client.DmaMap.api and Client.DmaUnmap.api are defined in type_description_client.ml *)
    let clientDmaMap = field t "PJRT_Client_DmaMap" Client.DmaMap.api
    let clientDmaUnmap = field t "PJRT_Client_DmaUnmap" Client.DmaUnmap.api
    let () = seal t
    let const_t = ptr @@ const t
  end

  let init = typedef (static_funptr (void @-> returning Api.const_t)) @@ ns "init"

  module Dl = struct
    type t

    let t : t structure typ = structure (ns "t")
    let handle = field t "handle" (ptr void)
    let init = field t "init" init
    let () = seal t
  end
end
