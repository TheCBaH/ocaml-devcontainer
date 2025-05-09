open Ctypes
open Pjrt_base.Type_description

module Types (F : Cstubs.Types.TYPE) = struct
  open Pjrt_base.Type_description.Base (F)
  open F

  module DeviceDescription = struct
    (* Device descriptions may be associated with an actual device
     (via PJRT_Device_GetDescription), but they can also be used to describe a
     device that isn't currently available to the plugin. This is useful for
     compiling executables without hardware available, which can then be
     serialized and written somewhere durable, and then loaded and run on actual
     hardware later. *)
    module Id = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "DeviceDescription_Id_Args"
        let device_description = field t "device_description" @@ ptr deviceDescription
        let id = field t "id" int (* out *)
        let () = seal t
      end

      (* The ID of this device. IDs are unique among devices of this type
         (e.g. CPUs, GPUs). On multi-host platforms, this will be unique across all
         hosts' devices. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "DeviceDescription_Id"
    end

    module ProcessIndex = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) =
          pjrt_struct "DeviceDescription_ProcessIndex_Args"

        let device_description = field t "device_description" @@ ptr deviceDescription
        let process_index = field t "process_index" int (* out *)
        let () = seal t
      end

      (* The index of the process that this device belongs to, i.e. is addressable
         from. This is not always identical to PJRT_Client_ProcessIndex in a
         multi-process setting, where each client can see devices from all
         processes, but only a subset of them are addressable and have the same
         process_index as the client. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "DeviceDescription_ProcessIndex"
    end

    module Attributes = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "DeviceDescription_Attributes_Args"
        let device_description = field t "device_description" @@ ptr deviceDescription
        let num_attributes = field t "num_attributes" size_t (* out *)
        let attributes = field t "attributes" @@ ptr (const namedValue) (* out *)
        let () = seal t
      end

      (* Returns an array of device specific attributes with attribute name, value
         and value type. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "DeviceDescription_Attributes"
    end

    module Kind = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "DeviceDescription_Kind_Args"
        let device_description = field t "device_description" @@ ptr deviceDescription

        (* `device_kind` string is owned by `device` and has same lifetime as
           `device`. *)
        let device_kind = field t "device_kind" string (* out *)
        let device_kind_size = field t "device_kind_size" size_t (* out *)
        let () = seal t
      end

      (* A vendor-dependent string that uniquely identifies the kind of device,
         e.g. "Tesla T4". *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "DeviceDescription_Kind"
    end

    module DebugString = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "DeviceDescription_DebugString_Args"
        let device_description = field t "device_description" @@ ptr deviceDescription
        let debug_string = field t "debug_string" string (* out *)
        let debug_string_size = field t "debug_string_size" size_t (* out *)
        let () = seal t
      end

      (* Debug string suitable for logging when errors occur. Should be verbose
         enough to identify the exact device, e.g., its complete name. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "DeviceDescription_DebugString"
    end

    module ToString = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "DeviceDescription_ToString_Args"
        let device_description = field t "device_description" @@ ptr deviceDescription
        let to_string = field t "to_string" string (* out *)
        let to_string_size = field t "to_string_size" size_t (* out *)
        let () = seal t
      end

      (* Debug string suitable for reading by end users, should be reasonably terse,
         for example: "CpuDevice(id=0)". *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "DeviceDescription_ToString"
    end
  end

  module Device = struct
    module GetDescription = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Device_GetDescription_Args"
        let device = field t "device" @@ ptr device
        let device_description = field t "device_description" @@ ptr (const deviceDescription) (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Device_GetDescription"
    end

    module IsAddressable = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Device_IsAddressable_Args"
        let device = field t "device" @@ ptr device
        let is_addressable = field t "is_addressable" bool (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Device_IsAddressable"
    end

    module LocalHardwareId = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Device_LocalHardwareId_Args"
        let device = field t "device" @@ ptr device
        let local_hardware_id = field t "local_hardware_id" int (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Device_LocalHardwareId"
    end

    module AddressableMemories = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Device_AddressableMemories_Args"
        let device = field t "device" @@ ptr device
        let memories = field t "memories" @@ ptr (ptr memory) (* out *)
        let num_memories = field t "num_memories" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Device_AddressableMemories"
    end

    module DefaultMemory = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Device_DefaultMemory_Args"
        let device = field t "device" @@ ptr device
        let memory = field t "memory" @@ ptr memory (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Device_DefaultMemory"
    end

    module MemoryStats = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Device_MemoryStats_Args"
        let device = field t "device" @@ ptr device
        let bytes_in_use = field t "bytes_in_use" int64_t (* out *)
        let peak_bytes_in_use = field t "peak_bytes_in_use" int64_t (* out *)
        let peak_bytes_in_use_is_set = field t "peak_bytes_in_use_is_set" bool (* out *)
        let num_allocs = field t "num_allocs" int64_t (* out *)
        let num_allocs_is_set = field t "num_allocs_is_set" bool (* out *)
        let largest_alloc_size = field t "largest_alloc_size" int64_t (* out *)
        let largest_alloc_size_is_set = field t "largest_alloc_size_is_set" bool (* out *)
        let bytes_limit = field t "bytes_limit" int64_t (* out *)
        let bytes_limit_is_set = field t "bytes_limit_is_set" bool (* out *)
        let bytes_reserved = field t "bytes_reserved" int64_t (* out *)
        let bytes_reserved_is_set = field t "bytes_reserved_is_set" bool (* out *)
        let peak_bytes_reserved = field t "peak_bytes_reserved" int64_t (* out *)
        let peak_bytes_reserved_is_set = field t "peak_bytes_reserved_is_set" bool (* out *)
        let bytes_reservable_limit = field t "bytes_reservable_limit" int64_t (* out *)
        let bytes_reservable_limit_is_set = field t "bytes_reservable_limit_is_set" bool (* out *)
        let largest_free_block_bytes = field t "largest_free_block_bytes" int64_t (* out *)
        let largest_free_block_bytes_is_set = field t "largest_free_block_bytes_is_set" bool (* out *)
        let pool_bytes = field t "pool_bytes" int64_t (* out *)
        let pool_bytes_is_set = field t "pool_bytes_is_set" bool (* out *)
        let peak_pool_bytes = field t "peak_pool_bytes" int64_t (* out *)
        let peak_pool_bytes_is_set = field t "peak_pool_bytes_is_set" bool (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Device_MemoryStats"
    end
  end

  module Memory = struct
    module Id = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Memory_Id_Args"
        let memory = field t "memory" @@ ptr memory
        let id = field t "id" int (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Memory_Id"
    end

    module Kind = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Memory_Kind_Args"
        let memory = field t "memory" @@ ptr memory
        let kind = field t "kind" string (* out *)
        let kind_size = field t "kind_size" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Memory_Kind"
    end

    module KindId = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Memory_Kind_Id_Args"
        let memory = field t "memory" @@ ptr memory
        let kind_id = field t "kind_id" int (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Memory_Kind_Id"
    end

    module DebugString = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Memory_DebugString_Args"
        let memory = field t "memory" @@ ptr memory
        let debug_string = field t "debug_string" string (* out *)
        let debug_string_size = field t "debug_string_size" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Memory_DebugString"
    end

    module ToString = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Memory_ToString_Args"
        let memory = field t "memory" @@ ptr memory
        let to_string = field t "to_string" string (* out *)
        let to_string_size = field t "to_string_size" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Memory_ToString"
    end

    module AddressableByDevices = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Memory_AddressableByDevices_Args"
        let memory = field t "memory" @@ ptr memory
        let devices = field t "devices" @@ ptr (ptr device) (* out *)
        let num_devices = field t "num_devices" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Memory_AddressableByDevices"
    end
  end

  module ExecuteContext = struct
    module Create = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "ExecuteContext_Create_Args"

        (* Add fields based on PJRT_ExecuteContext_Create_Args if any, typically for options or context pointers *)
        let context = field t "context" @@ ptr executeContext (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "ExecuteContext_Create"
    end

    module Destroy = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "ExecuteContext_Destroy_Args"
        let context = field t "context" @@ ptr executeContext
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "ExecuteContext_Destroy"
    end
  end

  module Executable = struct
    let serializedExecutable : [ `SerializedExecutable ] structure typ = snd @@ make_struct_base "SerializedExecutable"

    module Destroy = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_Destroy_Args"
        let executable = field t "executable" @@ ptr executable
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Executable_Destroy"
    end

    module Name = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_Name_Args"
        let executable = field t "executable" @@ ptr executable
        let executable_name = field t "executable_name" string (* out *)
        let executable_name_size = field t "executable_name_size" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Executable_Name"
    end

    module NumReplicas = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_NumReplicas_Args"
        let executable = field t "executable" @@ ptr executable
        let num_replicas = field t "num_replicas" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Executable_NumReplicas"
    end

    module NumPartitions = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_NumPartitions_Args"
        let executable = field t "executable" @@ ptr executable
        let num_partitions = field t "num_partitions" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Executable_NumPartitions"
    end

    module OptimizedProgram = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_OptimizedProgram_Args"
        let executable = field t "executable" @@ ptr executable
        let program = field t "program" @@ ptr program (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Executable_OptimizedProgram"
    end

    module NumOutputs = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_NumOutputs_Args"
        let executable = field t "executable" @@ ptr executable
        let num_outputs = field t "num_outputs" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Executable_NumOutputs"
    end

    module SizeOfGeneratedCodeInBytes = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) =
          pjrt_struct "Executable_SizeOfGeneratedCodeInBytes_Args"

        let executable = field t "executable" @@ ptr executable
        let size_in_bytes = field t "size_in_bytes" int64_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Executable_SizeOfGeneratedCodeInBytes"
    end

    module Fingerprint = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_Fingerprint_Args"
        let executable = field t "executable" @@ ptr executable
        let executable_fingerprint = field t "executable_fingerprint" string (* out *)
        let executable_fingerprint_size = field t "executable_fingerprint_size" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Executable_Fingerprint"
    end

    module GetCostAnalysis = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_GetCostAnalysis_Args"
        let executable = field t "executable" @@ ptr executable
        let num_properties = field t "num_properties" size_t (* out *)
        let properties = field t "properties" @@ ptr (const namedValue) (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Executable_GetCostAnalysis"
    end

    module GetCompiledMemoryStats = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) =
          pjrt_struct "Executable_GetCompiledMemoryStats_Args"

        let executable = field t "executable" @@ ptr executable
        let generated_code_size_in_bytes = field t "generated_code_size_in_bytes" int64_t (* out *)
        let argument_size_in_bytes = field t "argument_size_in_bytes" int64_t (* out *)
        let output_size_in_bytes = field t "output_size_in_bytes" int64_t (* out *)
        let alias_size_in_bytes = field t "alias_size_in_bytes" int64_t (* out *)
        let temp_size_in_bytes = field t "temp_size_in_bytes" int64_t (* out *)
        let host_generated_code_size_in_bytes = field t "host_generated_code_size_in_bytes" int64_t (* out *)
        let host_argument_size_in_bytes = field t "host_argument_size_in_bytes" int64_t (* out *)
        let host_output_size_in_bytes = field t "host_output_size_in_bytes" int64_t (* out *)
        let host_alias_size_in_bytes = field t "host_alias_size_in_bytes" int64_t (* out *)
        let host_temp_size_in_bytes = field t "host_temp_size_in_bytes" int64_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Executable_GetCompiledMemoryStats"
    end

    module OutputElementTypes = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_OutputElementTypes_Args"
        let executable = field t "executable" @@ ptr executable
        let output_types = field t "output_types" @@ ptr uint

        (* should be bufferType *)
        (* out - PJRT_Buffer_Type* *)
        let num_output_types = field t "num_output_types" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Executable_OutputElementTypes"
    end

    module OutputDimensions = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_OutputDimensions_Args"
        let executable = field t "executable" @@ ptr executable
        let num_outputs = field t "num_outputs" size_t (* in *)
        let dims = field t "dims" @@ ptr (const int64_t) (* out *)
        let dim_sizes = field t "dim_sizes" @@ ptr (const size_t) (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Executable_OutputDimensions"
    end

    module OutputMemoryKinds = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_OutputMemoryKinds_Args"
        let executable = field t "executable" @@ ptr executable
        let num_outputs = field t "num_outputs" size_t (* in *)
        let memory_kinds = field t "memory_kinds" @@ ptr (ptr (const char)) (* out const char* const* *)
        let memory_kind_sizes = field t "memory_kind_sizes" @@ ptr (const size_t) (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Executable_OutputMemoryKinds"
    end

    module Serialize = struct
      let deleter = static_funptr (ptr serializedExecutable @-> returning void)

      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_Serialize_Args"
        let executable = field t "executable" @@ ptr (const executable) (* C API is const PJRT_Executable* *)
        let serialized_bytes = field t "serialized_bytes" string (* out const char* *)
        let serialized_bytes_size = field t "serialized_bytes_size" size_t (* out *)

        let serialized_executable =
          field t "serialized_executable" @@ ptr serializedExecutable (* out PJRT_SerializedExecutable* *)

        let serialized_executable_deleter = field t "serialized_executable_deleter" deleter (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Executable_Serialize"
    end

    (* PJRT_Executable_DeserializeAndLoad is more related to client, might move later *)
    module DeserializeAndLoad = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_DeserializeAndLoad_Args"
        let client = field t "client" @@ ptr client
        let serialized_executable = field t "serialized_executable" string
        let serialized_executable_size = field t "serialized_executable_size" size_t
        let loaded_executable = field t "loaded_executable" @@ ptr loadedExecutable (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Executable_DeserializeAndLoad"
    end
  end

  module LoadedExecutable = struct
    module Destroy = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "LoadedExecutable_Destroy_Args"
        let executable = field t "executable" @@ ptr loadedExecutable
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "LoadedExecutable_Destroy"
    end

    module GetExecutable = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) =
          pjrt_struct "LoadedExecutable_GetExecutable_Args"

        let loaded_executable = field t "loaded_executable" @@ ptr loadedExecutable
        let executable = field t "executable" @@ ptr executable (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "LoadedExecutable_GetExecutable"
    end

    module AddressableDevices = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) =
          pjrt_struct "LoadedExecutable_AddressableDevices_Args"

        let executable = field t "executable" @@ ptr loadedExecutable
        let addressable_devices = field t "addressable_devices" @@ ptr (ptr device) (* out *)
        let num_addressable_devices = field t "num_addressable_devices" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "LoadedExecutable_AddressableDevices"
    end

    module Delete = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "LoadedExecutable_Delete_Args"
        let executable = field t "executable" @@ ptr loadedExecutable
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "LoadedExecutable_Delete"
    end

    module IsDeleted = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "LoadedExecutable_IsDeleted_Args"
        let executable = field t "executable" @@ ptr loadedExecutable
        let is_deleted = field t "is_deleted" bool (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "LoadedExecutable_IsDeleted"
    end

    module Execute = struct
      module Chunk = struct
        type t

        let _, (t : t structure typ) = make_struct_base "Chunk"
        let size = field t "size" size_t

        let deleter =
          field t "deleter" @@ static_funptr (ptr void (* data *) @-> ptr void (* deleter_arg *) @-> returning void)

        (* `deleter_arg` will be passed to `deleter` as `deleter_arg` argument. *)
        let deleter_arg = field t "deleter_arg" @@ ptr void
        let () = seal t
      end

      let sendCallback =
        typedef
          (static_funptr
             (ptr Chunk.t (* chunk *) @-> ptr callbackError
             (* callback_error *) @-> size_t
             (* total_size_in_bytes *) @-> bool
             (* done *) @-> ptr void
             (* user_arg *) @-> returning
             @@ ptr error))
        @@ _NS "SendCallback"

      let recvCallback =
        typedef (static_funptr (ptr copyToDeviceStream (* stream *) @-> ptr void (* user_arg *) @-> returning void))
        @@ _NS "RecvCallback"

      module SendCallbackInfo = struct
        type t

        let _, size, (t : t structure typ) = make_struct_traits "SendCallbackInfo"

        (* Used to associate this callback with the correct send op. *)
        let channel_id = field t "channel_id" int64_t

        (*  Will be passed to `send_callback` as `user_arg` argument. *)
        let user_arg = field t "user_arg" @@ ptr void
        let send_callback = field t "send_callback" sendCallback
        let () = seal t
      end

      module RecvCallbackInfo = struct
        type t

        let _, size, (t : t structure typ) = make_struct_traits "RecvCallbackInfo"

        (* Used to associate this callback with the correct recv op. *)
        let channel_id = field t "channel_id" int64_t

        (*  Will be passed to `recv_callback` as `user_arg` argument. *)
        let user_arg = field t "user_arg" @@ ptr void
        let recv_callback = field t "recv_callback" recvCallback
        let () = seal t
      end

      module Options = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "ExecuteOptions"
        let () = seal t
      end

      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "LoadedExecutable_Execute_Args"
        let executable = field t "executable" @@ ptr executable
        let options = field t "options" @@ ptr Options.t
        let argument_lists = field t "argument_lists" @@ ptr (ptr (ptr buffer)) (* PJRT_Buffer* const* const* *)
        let num_devices = field t "num_devices" size_t
        let num_args = field t "num_args" size_t
        let output_lists = field t "output_lists" @@ ptr (ptr (ptr buffer))

        (* PJRT_Buffer** const* output_lists;  in/out *)
        let device_complete_events = field t "device_complete_events" @@ ptr (ptr event) (* in/out *)
        let execute_device = field t "execute_device" @@ ptr device
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "LoadedExecutable_Execute"
    end

    module Fingerprint = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "LoadedExecutable_Fingerprint_Args"

        let executable =
          field t "executable" @@ ptr loadedExecutable (* C struct uses 'executable' for PJRT_LoadedExecutable* *)

        let executable_fingerprint = field t "executable_fingerprint" string (* out *)
        let executable_fingerprint_size = field t "executable_fingerprint_size" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "LoadedExecutable_Fingerprint"
    end
  end
end
