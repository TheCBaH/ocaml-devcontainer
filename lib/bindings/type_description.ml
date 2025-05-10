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

  (*
  module Compile = struct
    module Args = struct
      type t
      let extension_start, struct_size, size, (t_struct : t structure typ) = pjrt_struct "Compile_Args"
      let topology = field t_struct "topology" (ptr (const topologyDescription))
      let program_ptr = field t_struct "program" (ptr (const program)) (* Renamed to avoid conflict if 'program' is a keyword/type *)
      let compile_options = field t_struct "compile_options" string
      let compile_options_size = field t_struct "compile_options_size" size_t
      let client_ptr = field t_struct "client" (ptr client) (* Renamed, optional, can be null *)
      let executable_ptr = field t_struct "executable" (ptr executable) (* Renamed, out *)
      let () = seal t_struct
    end
    (* Compiles a program in specified format (such as MLIR or HLO) with given
       `options`. The returned executable must be loaded by a compatible
       PJRT_Client before execution. *)
    let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Compile"
  end
  *)
  (*
  module Api = struct
    type t

    let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Api"

    let api_version_field = field t "pjrt_api_version" Version.t

    let errorDestroy = field t "PJRT_Error_Destroy" (ptr Error.Destroy.api)
    let errorMessage = field t "PJRT_Error_Message" (ptr Error.Message.api)
    let errorGetCode = field t "PJRT_Error_GetCode" (ptr Error.GetCode.api)

    let pluginInitialize = field t "PJRT_Plugin_Initialize" (ptr Plugin.Initialize.api)
    *)
  (*
    let pJRT_Plugin_Attributes = field _struct "PJRT_Plugin_Attributes" (ptr Plugin.Attributes.api)

    let pJRT_Event_Destroy = field _struct "PJRT_Event_Destroy" (ptr Event.Destroy.api)
    let pJRT_Event_IsReady = field _struct "PJRT_Event_IsReady" (ptr Event.IsReady.api)
    let pJRT_Event_Error = field _struct "PJRT_Event_Error" (ptr Event.Error.api)
    let pJRT_Event_Await = field _struct "PJRT_Event_Await" (ptr Event.Await.api)
    let pJRT_Event_OnReady = field _struct "PJRT_Event_OnReady" (ptr Event.OnReady.api)

    let pJRT_Client_Create = field _struct "PJRT_Client_Create" (ptr Client.Create.api)
    let pJRT_Client_Destroy = field _struct "PJRT_Client_Destroy" (ptr Client.Destroy.api)
    let pJRT_Client_PlatformName = field _struct "PJRT_Client_PlatformName" (ptr Client.PlatformName.api)
    let pJRT_Client_ProcessIndex = field _struct "PJRT_Client_ProcessIndex" (ptr Client.ProcessIndex.api)
    let pJRT_Client_PlatformVersion = field _struct "PJRT_Client_PlatformVersion" (ptr Client.PlatformVersion.api)
    let pJRT_Client_Devices = field _struct "PJRT_Client_Devices" (ptr Client.Devices.api)
    let pJRT_Client_AddressableDevices = field _struct "PJRT_Client_AddressableDevices" (ptr Client.AddressableDevices.api)
    let pJRT_Client_LookupDevice = field _struct "PJRT_Client_LookupDevice" (ptr Client.LookupDevice.api)
    let pJRT_Client_LookupAddressableDevice = field _struct "PJRT_Client_LookupAddressableDevice" (ptr Client.LookupAddressableDevice.api)
    let pJRT_Client_AddressableMemories = field _struct "PJRT_Client_AddressableMemories" (ptr Client.AddressableMemories.api)
    let pJRT_Client_Compile = field _struct "PJRT_Client_Compile" (ptr Client.Compile.api)
    let pJRT_Client_DefaultDeviceAssignment = field _struct "PJRT_Client_DefaultDeviceAssignment" (ptr Client.DefaultDeviceAssignment.api)
    let pJRT_Client_BufferFromHostBuffer = field _struct "PJRT_Client_BufferFromHostBuffer" (ptr Client.BufferFromHostBuffer.api)

    let pJRT_DeviceDescription_Id = field _struct "PJRT_DeviceDescription_Id" (ptr DeviceDescription.Id.api)
    let pJRT_DeviceDescription_ProcessIndex = field _struct "PJRT_DeviceDescription_ProcessIndex" (ptr DeviceDescription.ProcessIndex.api)
    let pJRT_DeviceDescription_Attributes = field _struct "PJRT_DeviceDescription_Attributes" (ptr DeviceDescription.Attributes.api)
    let pJRT_DeviceDescription_Kind = field _struct "PJRT_DeviceDescription_Kind" (ptr DeviceDescription.Kind.api)
    let pJRT_DeviceDescription_DebugString = field _struct "PJRT_DeviceDescription_DebugString" (ptr DeviceDescription.DebugString.api)
    let pJRT_DeviceDescription_ToString = field _struct "PJRT_DeviceDescription_ToString" (ptr DeviceDescription.ToString.api)

    let pJRT_Device_GetDescription = field _struct "PJRT_Device_GetDescription" (ptr Device.GetDescription.api)
    let pJRT_Device_IsAddressable = field _struct "PJRT_Device_IsAddressable" (ptr Device.IsAddressable.api)
    let pJRT_Device_LocalHardwareId = field _struct "PJRT_Device_LocalHardwareId" (ptr Device.LocalHardwareId.api)
    let pJRT_Device_AddressableMemories = field _struct "PJRT_Device_AddressableMemories" (ptr Device.AddressableMemories.api)
    let pJRT_Device_DefaultMemory = field _struct "PJRT_Device_DefaultMemory" (ptr Device.DefaultMemory.api)
    let pJRT_Device_MemoryStats = field _struct "PJRT_Device_MemoryStats" (ptr Device.MemoryStats.api)

    let pJRT_Memory_Id = field _struct "PJRT_Memory_Id" (ptr Memory.Id.api)
    let pJRT_Memory_Kind = field _struct "PJRT_Memory_Kind" (ptr Memory.Kind.api)
    let pJRT_Memory_DebugString = field _struct "PJRT_Memory_DebugString" (ptr Memory.DebugString.api)
    let pJRT_Memory_ToString = field _struct "PJRT_Memory_ToString" (ptr Memory.ToString.api)
    let pJRT_Memory_AddressableByDevices = field _struct "PJRT_Memory_AddressableByDevices" (ptr Memory.AddressableByDevices.api)

    let pJRT_Executable_Destroy = field _struct "PJRT_Executable_Destroy" (ptr Executable.Destroy.api)
    let pJRT_Executable_Name = field _struct "PJRT_Executable_Name" (ptr Executable.Name.api)
    let pJRT_Executable_NumReplicas = field _struct "PJRT_Executable_NumReplicas" (ptr Executable.NumReplicas.api)
    let pJRT_Executable_NumPartitions = field _struct "PJRT_Executable_NumPartitions" (ptr Executable.NumPartitions.api)
    let pJRT_Executable_NumOutputs = field _struct "PJRT_Executable_NumOutputs" (ptr Executable.NumOutputs.api)
    let pJRT_Executable_SizeOfGeneratedCodeInBytes = field _struct "PJRT_Executable_SizeOfGeneratedCodeInBytes" (ptr Executable.SizeOfGeneratedCodeInBytes.api)
    let pJRT_Executable_GetCostAnalysis = field _struct "PJRT_Executable_GetCostAnalysis" (ptr Executable.GetCostAnalysis.api)
    let pJRT_Executable_OutputMemoryKinds = field _struct "PJRT_Executable_OutputMemoryKinds" (ptr Executable.OutputMemoryKinds.api)
    let pJRT_Executable_OptimizedProgram = field _struct "PJRT_Executable_OptimizedProgram" (ptr Executable.OptimizedProgram.api)
    let pJRT_Executable_Serialize = field _struct "PJRT_Executable_Serialize" (ptr Executable.Serialize.api)

    let pJRT_LoadedExecutable_Destroy = field _struct "PJRT_LoadedExecutable_Destroy" (ptr LoadedExecutable.Destroy.api)
    let pJRT_LoadedExecutable_GetExecutable = field _struct "PJRT_LoadedExecutable_GetExecutable" (ptr LoadedExecutable.GetExecutable.api)
    let pJRT_LoadedExecutable_AddressableDevices = field _struct "PJRT_LoadedExecutable_AddressableDevices" (ptr LoadedExecutable.AddressableDevices.api)
    let pJRT_LoadedExecutable_Delete = field _struct "PJRT_LoadedExecutable_Delete" (ptr LoadedExecutable.Delete.api)
    let pJRT_LoadedExecutable_IsDeleted = field _struct "PJRT_LoadedExecutable_IsDeleted" (ptr LoadedExecutable.IsDeleted.api)
    let pJRT_LoadedExecutable_Execute = field _struct "PJRT_LoadedExecutable_Execute" (ptr LoadedExecutable.Execute.api)
    let pJRT_Executable_DeserializeAndLoad = field _struct "PJRT_Executable_DeserializeAndLoad" (ptr Executable.DeserializeAndLoad.api)
    let pJRT_LoadedExecutable_Fingerprint = field _struct "PJRT_LoadedExecutable_Fingerprint" (ptr LoadedExecutable.Fingerprint.api)

    let pJRT_Buffer_Destroy = field _struct "PJRT_Buffer_Destroy" (ptr Buffer.Destroy.api)
    let pJRT_Buffer_ElementType = field _struct "PJRT_Buffer_ElementType" (ptr Buffer.ElementType.api)
    let pJRT_Buffer_Dimensions = field _struct "PJRT_Buffer_Dimensions" (ptr Buffer.Dimensions.api)
    let pJRT_Buffer_UnpaddedDimensions = field _struct "PJRT_Buffer_UnpaddedDimensions" (ptr Buffer.UnpaddedDimensions.api)
    let pJRT_Buffer_DynamicDimensionIndices = field _struct "PJRT_Buffer_DynamicDimensionIndices" (ptr Buffer.DynamicDimensionIndices.api)
    let pJRT_Buffer_GetMemoryLayout = field _struct "PJRT_Buffer_GetMemoryLayout" (ptr Buffer.GetMemoryLayout.api)
    let pJRT_Buffer_OnDeviceSizeInBytes = field _struct "PJRT_Buffer_OnDeviceSizeInBytes" (ptr Buffer.OnDeviceSizeInBytes.api)
    let pJRT_Buffer_Device = field _struct "PJRT_Buffer_Device" (ptr Buffer.Device.api)
    let pJRT_Buffer_Memory = field _struct "PJRT_Buffer_Memory" (ptr Buffer.Memory.api)
    let pJRT_Buffer_Delete = field _struct "PJRT_Buffer_Delete" (ptr Buffer.Delete.api)
    let pJRT_Buffer_IsDeleted = field _struct "PJRT_Buffer_IsDeleted" (ptr Buffer.IsDeleted.api)
    let pJRT_Buffer_CopyToDevice = field _struct "PJRT_Buffer_CopyToDevice" (ptr Buffer.CopyToDevice.api)
    let pJRT_Buffer_ToHostBuffer = field _struct "PJRT_Buffer_ToHostBuffer" (ptr Buffer.ToHostBuffer.api)
    let pJRT_Buffer_IsOnCpu = field _struct "PJRT_Buffer_IsOnCpu" (ptr Buffer.IsOnCpu.api)
    let pJRT_Buffer_ReadyEvent = field _struct "PJRT_Buffer_ReadyEvent" (ptr Buffer.ReadyEvent.api)
    let pJRT_Buffer_UnsafePointer = field _struct "PJRT_Buffer_UnsafePointer" (ptr Buffer.UnsafePointer.api)
    let pJRT_Buffer_IncreaseExternalReferenceCount = field _struct "PJRT_Buffer_IncreaseExternalReferenceCount" (ptr Buffer.IncreaseExternalReferenceCount.api)
    let pJRT_Buffer_DecreaseExternalReferenceCount = field _struct "PJRT_Buffer_DecreaseExternalReferenceCount" (ptr Buffer.DecreaseExternalReferenceCount.api)
    let pJRT_Buffer_OpaqueDeviceMemoryDataPointer = field _struct "PJRT_Buffer_OpaqueDeviceMemoryDataPointer" (ptr Buffer.OpaqueDeviceMemoryDataPointer.api)

    let pJRT_CopyToDeviceStream_Destroy = field _struct "PJRT_CopyToDeviceStream_Destroy" (ptr CopyDeviceStream.Destroy.api)
    let pJRT_CopyToDeviceStream_AddChunk = field _struct "PJRT_CopyToDeviceStream_AddChunk" (ptr CopyDeviceStream.AddChunk.api)
    let pJRT_CopyToDeviceStream_TotalBytes = field _struct "PJRT_CopyToDeviceStream_TotalBytes" (ptr CopyDeviceStream.TotalBytes.api)
    let pJRT_CopyToDeviceStream_GranuleSize = field _struct "PJRT_CopyToDeviceStream_GranuleSize" (ptr CopyDeviceStream.GranuleSize.api)
    let pJRT_CopyToDeviceStream_CurrentBytes = field _struct "PJRT_CopyToDeviceStream_CurrentBytes" (ptr CopyDeviceStream.CurrentBytes.api)

    let pJRT_TopologyDescription_Create = field _struct "PJRT_TopologyDescription_Create" (ptr TopologyDescription.Create.api)
    let pJRT_TopologyDescription_Destroy = field _struct "PJRT_TopologyDescription_Destroy" (ptr TopologyDescription.Destroy.api)
    let pJRT_TopologyDescription_PlatformName = field _struct "PJRT_TopologyDescription_PlatformName" (ptr TopologyDescription.PlatformName.api)
    let pJRT_TopologyDescription_PlatformVersion = field _struct "PJRT_TopologyDescription_PlatformVersion" (ptr TopologyDescription.PlatformVersion.api)
    let pJRT_TopologyDescription_GetDeviceDescriptions = field _struct "PJRT_TopologyDescription_GetDeviceDescriptions" (ptr TopologyDescription.GetDeviceDescriptions.api)
    let pJRT_TopologyDescription_Serialize = field _struct "PJRT_TopologyDescription_Serialize" (ptr TopologyDescription.Serialize.api)
    let pJRT_TopologyDescription_Attributes = field _struct "PJRT_TopologyDescription_Attributes" (ptr TopologyDescription.Attributes.api)

    let pJRT_Compile = field _struct "PJRT_Compile" (ptr Compile.api)

    let pJRT_Executable_OutputElementTypes = field _struct "PJRT_Executable_OutputElementTypes" (ptr Executable.OutputElementTypes.api)
    let pJRT_Executable_OutputDimensions = field _struct "PJRT_Executable_OutputDimensions" (ptr Executable.OutputDimensions.api)
    let pJRT_Buffer_CopyToMemory = field _struct "PJRT_Buffer_CopyToMemory" (ptr Buffer.CopyToMemory.api)
    (* Assuming Client.CreateViewOfDeviceBuffer.api is defined in type_description_client.ml *)
    let pJRT_Client_CreateViewOfDeviceBuffer = field _struct "PJRT_Client_CreateViewOfDeviceBuffer" (ptr Client.CreateViewOfDeviceBuffer.api)
    let pJRT_Executable_Fingerprint = field _struct "PJRT_Executable_Fingerprint" (ptr Executable.Fingerprint.api)
    (* Assuming Client.TopologyDescription.api is defined in type_description_client.ml *)
    let pJRT_Client_TopologyDescription = field _struct "PJRT_Client_TopologyDescription" (ptr Client.TopologyDescription.api)
    let pJRT_Executable_GetCompiledMemoryStats = field _struct "PJRT_Executable_GetCompiledMemoryStats" (ptr Executable.GetCompiledMemoryStats.api)
    let pJRT_Memory_Kind_Id = field _struct "PJRT_Memory_Kind_Id" (ptr Memory.KindId.api)
    let pJRT_ExecuteContext_Create = field _struct "PJRT_ExecuteContext_Create" (ptr ExecuteContext.Create.api)
    let pJRT_ExecuteContext_Destroy = field _struct "PJRT_ExecuteContext_Destroy" (ptr ExecuteContext.Destroy.api)
    let pJRT_Buffer_CopyRawToHost = field _struct "PJRT_Buffer_CopyRawToHost" (ptr Buffer.CopyRawToHost.api)

    (* PJRT_AsyncHostToDeviceTransferManager and its functions are omitted for now,
       as their OCaml types (e.g., AsyncHostToDeviceTransferManager.Destroy.api)
       are assumed not to be defined yet. *)
    (* Assuming Client.CreateBuffersForAsyncHostToDevice.api is defined in type_description_client.ml *)
    let pJRT_Client_CreateBuffersForAsyncHostToDevice = field _struct "PJRT_Client_CreateBuffersForAsyncHostToDevice" (ptr Client.CreateBuffersForAsyncHostToDevice.api)

    (* Assuming Client.DmaMap.api and Client.DmaUnmap.api are defined in type_description_client.ml *)
    let pJRT_Client_DmaMap = field _struct "PJRT_Client_DmaMap" (ptr Client.DmaMap.api)
    let pJRT_Client_DmaUnmap = field _struct "PJRT_Client_DmaUnmap" (ptr Client.DmaUnmap.api)

    let () = seal t
    let const_t = ptr @@ const t
  end
    *)

  let init = typedef (static_funptr (void @-> returning void (* Api.t *))) @@ ns "init"

  module Dl = struct
    type t

    let t : t structure typ = structure (ns "t")
    let handle = field t "handle" (ptr void)
    let init = field t "init" init
    let () = seal t
  end
end
