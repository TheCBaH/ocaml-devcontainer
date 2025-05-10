open Ctypes
open Pjrt_base.Type_description

module Types (F : Cstubs.Types.TYPE) = struct
  open Pjrt_base.Type_description.Base (F)
  open F

  module Chunk = struct
    type t

    let _, (t : t structure typ) = make_struct_base "Chunk" (* Note: PJRT_Chunk is not a pjrt_struct *)
    let data = field t "data" @@ ptr void
    let size = field t "size" size_t

    let deleter =
      field t "deleter" @@ static_funptr (ptr void (* data *) @-> ptr void (* deleter_arg *) @-> returning void)

    (* `deleter_arg` will be passed to `deleter` as `deleter_arg` argument. *)
    let deleter_arg = field t "deleter_arg" @@ ptr void
    let () = seal t
  end

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
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "DeviceDescription_Id"
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
      let api =
        typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "DeviceDescription_ProcessIndex"
    end

    module Attributes = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "DeviceDescription_Attributes_Args"
        let device_description = field t "device_description" @@ ptr deviceDescription
        let num_attributes = field t "num_attributes" size_t (* out *)

        (* `attributes` has the lifetime of `device_description`. *)
        let attributes = field t "attributes" @@ ptr (const namedValue) (* out *)
        let () = seal t
      end

      (* Returns an array of device specific attributes with attribute name, value
         and value type. *)
      let api =
        typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "DeviceDescription_Attributes"
    end

    module Kind = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "DeviceDescription_Kind_Args"
        let device_description = field t "device_description" @@ ptr deviceDescription

        (* `device_kind` string is owned by `device_description` and has same lifetime
           as `device_description`. *)
        let device_kind = field t "device_kind" string (* out *)
        let device_kind_size = field t "device_kind_size" size_t (* out *)
        let () = seal t
      end

      (* A vendor-dependent string that uniquely identifies the kind of device,
         e.g. "Tesla T4". *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "DeviceDescription_Kind"
    end

    module DebugString = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "DeviceDescription_DebugString_Args"
        let device_description = field t "device_description" @@ ptr deviceDescription

        (* `debug_string` has the lifetime of `device_description`. *)
        let debug_string = field t "debug_string" string (* out *)
        let debug_string_size = field t "debug_string_size" size_t (* out *)
        let () = seal t
      end

      (* Debug string suitable for logging when errors occur. Should be verbose
         enough to identify the exact device, e.g., its complete name. *)
      let api =
        typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "DeviceDescription_DebugString"
    end

    module ToString = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "DeviceDescription_ToString_Args"
        let device_description = field t "device_description" @@ ptr deviceDescription

        (* `to_string` has the lifetime of `device_description`. *)
        let to_string = field t "to_string" string (* out *)
        let to_string_size = field t "to_string_size" size_t (* out *)
        let () = seal t
      end

      (* Debug string suitable for reading by end users, should be reasonably terse,
         for example: "CpuDevice(id=0)". *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "DeviceDescription_ToString"
    end
  end

  (* PJRT_Device is an opaque, PJRT implementation-specific type that represents a
     device.

     It is the responsibility of the plugin to manage the memory for this struct.
     PJRT_Device structs are not owned by the client. *)
  module Device = struct
    module GetDescription = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Device_GetDescription_Args"
        let device = field t "device" @@ ptr device

        (* The returned `device_description` is owned by and has the same lifetime as
           `device`. *)
        let device_description = field t "device_description" @@ ptr (const deviceDescription) (* out *)
        let () = seal t
      end

      (* Returns a PJRT_DeviceDescription that describes `device`. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Device_GetDescription"
    end

    module IsAddressable = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Device_IsAddressable_Args"
        let device = field t "device" @@ ptr device
        let is_addressable = field t "is_addressable" bool (* out *)
        let () = seal t
      end

      (* Whether client can issue commands to this device. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Device_IsAddressable"
    end

    module LocalHardwareId = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Device_LocalHardwareId_Args"
        let device = field t "device" @@ ptr device

        (* Opaque hardware ID, e.g. the CUDA device number. In general, not guaranteed
           to be dense, and -1 if invalid. *)
        let local_hardware_id = field t "local_hardware_id" int (* out *)
        let () = seal t
      end

      (* An opaque ID that can be used to compare with the `local_hardware_id` in
         `PJRT_DeviceDescription`. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Device_LocalHardwareId"
    end

    module AddressableMemories = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Device_AddressableMemories_Args"
        let device = field t "device" @@ ptr device

        (* `memories` has the lifetime of `device`. *)
        let memories = field t "memories" @@ ptr (ptr memory) (* out *)
        let num_memories = field t "num_memories" size_t (* out *)
        let () = seal t
      end

      (* Returns all memories that are addressable from `device`. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Device_AddressableMemories"
    end

    module DefaultMemory = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Device_DefaultMemory_Args"
        let device = field t "device" @@ ptr device

        (* `memory` has the lifetime of `device`. *)
        let memory = field t "memory" @@ ptr memory (* out *)
        let () = seal t
      end

      (* Returns the default memory for a device. This memory is addressable from
         `device`. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Device_DefaultMemory"
    end

    module MemoryStats = struct
      (* All PJRT_Device_MemoryStats_Args `*_is_set` fields are true if the
         corresponding stat is available from the plugin, and false otherwise.

         All byte counts are in bytes. *)
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Device_MemoryStats_Args"
        let device = field t "device" @@ ptr device

        (* Current bytes in use by the program. *)
        let bytes_in_use = field t "bytes_in_use" int64_t (* out *)

        (* Peak bytes in use by the program. *)
        let peak_bytes_in_use = field t "peak_bytes_in_use" int64_t (* out *)
        let peak_bytes_in_use_is_set = field t "peak_bytes_in_use_is_set" bool (* out *)

        (* Number of allocations by the program. *)
        let num_allocs = field t "num_allocs" int64_t (* out *)
        let num_allocs_is_set = field t "num_allocs_is_set" bool (* out *)

        (* Largest allocation by the program. *)
        let largest_alloc_size = field t "largest_alloc_size" int64_t (* out *)
        let largest_alloc_size_is_set = field t "largest_alloc_size_is_set" bool (* out *)

        (* The memory limit of the device. *)
        let bytes_limit = field t "bytes_limit" int64_t (* out *)
        let bytes_limit_is_set = field t "bytes_limit_is_set" bool (* out *)

        (* Current bytes reserved by the program. *)
        let bytes_reserved = field t "bytes_reserved" int64_t (* out *)
        let bytes_reserved_is_set = field t "bytes_reserved_is_set" bool (* out *)

        (* Peak bytes reserved by the program. *)
        let peak_bytes_reserved = field t "peak_bytes_reserved" int64_t (* out *)
        let peak_bytes_reserved_is_set = field t "peak_bytes_reserved_is_set" bool (* out *)

        (* The reservable memory limit of the device. *)
        let bytes_reservable_limit = field t "bytes_reservable_limit" int64_t (* out *)
        let bytes_reservable_limit_is_set = field t "bytes_reservable_limit_is_set" bool (* out *)

        (* Largest free block in the memory. *)
        let largest_free_block_bytes = field t "largest_free_block_bytes" int64_t (* out *)
        let largest_free_block_bytes_is_set = field t "largest_free_block_bytes_is_set" bool (* out *)

        (* Current bytes in the memory pool. *)
        let pool_bytes = field t "pool_bytes" int64_t (* out *)
        let pool_bytes_is_set = field t "pool_bytes_is_set" bool (* out *)

        (* Peak bytes in the memory pool. *)
        let peak_pool_bytes = field t "peak_pool_bytes" int64_t (* out *)
        let peak_pool_bytes_is_set = field t "peak_pool_bytes_is_set" bool (* out *)
        let () = seal t
      end

      (* Gets memory statistics for `device`. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Device_MemoryStats"
    end
  end

  (* PJRT_Memory is an opaque, PJRT implementation-specific type that represents a
     memory space.

     It is the responsibility of the plugin to manage the memory for this struct.
     PJRT_Memory structs are not owned by the client. *)
  module Memory = struct
    module Id = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Memory_Id_Args"
        let memory = field t "memory" @@ ptr memory
        let id = field t "id" int (* out *)
        let () = seal t
      end

      (* The ID of this memory. IDs are unique among memories of this type. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Memory_Id"
    end

    module Kind = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Memory_Kind_Args"
        let memory = field t "memory" @@ ptr memory

        (* `kind` has the lifetime of `memory`. *)
        let kind = field t "kind" string (* out *)
        let kind_size = field t "kind_size" size_t (* out *)
        let () = seal t
      end

      (* A platform-dependent string that identifies the kind of the memory. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Memory_Kind"
    end

    module KindId = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Memory_Kind_Id_Args"
        let memory = field t "memory" @@ ptr memory
        let kind_id = field t "kind_id" int (* out *)
        let () = seal t
      end

      (* A platform-dependent ID that identifies the kind of the memory. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Memory_Kind_Id"
    end

    module DebugString = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Memory_DebugString_Args"
        let memory = field t "memory" @@ ptr memory

        (* `debug_string` has the lifetime of `memory`. *)
        let debug_string = field t "debug_string" string (* out *)
        let debug_string_size = field t "debug_string_size" size_t (* out *)
        let () = seal t
      end

      (* Debug string suitable for logging when errors occur. Should be verbose enough
         to identify the exact memory, e.g., its complete name. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Memory_DebugString"
    end

    module ToString = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Memory_ToString_Args"
        let memory = field t "memory" @@ ptr memory

        (* `to_string` has the lifetime of `memory`. *)
        let to_string = field t "to_string" string (* out *)
        let to_string_size = field t "to_string_size" size_t (* out *)
        let () = seal t
      end

      (* Debug string suitable for reading by end users, should be reasonably terse. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Memory_ToString"
    end

    module AddressableByDevices = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Memory_AddressableByDevices_Args"
        let memory = field t "memory" @@ ptr memory

        (* `devices` has the lifetime of `memory`. *)
        let devices = field t "devices" @@ ptr (ptr device) (* out *)
        let num_devices = field t "num_devices" size_t (* out *)
        let () = seal t
      end

      (* Returns all devices that can address `memory`. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Memory_AddressableByDevices"
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

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "ExecuteContext_Create"
    end

    module Destroy = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "ExecuteContext_Destroy_Args"
        let context = field t "context" @@ ptr executeContext
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "ExecuteContext_Destroy"
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

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Executable_Destroy"
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

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Executable_Name"
    end

    module NumReplicas = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_NumReplicas_Args"
        let executable = field t "executable" @@ ptr executable
        let num_replicas = field t "num_replicas" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Executable_NumReplicas"
    end

    module NumPartitions = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_NumPartitions_Args"
        let executable = field t "executable" @@ ptr executable
        let num_partitions = field t "num_partitions" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Executable_NumPartitions"
    end

    module OptimizedProgram = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_OptimizedProgram_Args"
        let executable = field t "executable" @@ ptr executable
        let program = field t "program" @@ ptr program (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Executable_OptimizedProgram"
    end

    module NumOutputs = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_NumOutputs_Args"
        let executable = field t "executable" @@ ptr executable
        let num_outputs = field t "num_outputs" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Executable_NumOutputs"
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

      let api =
        typedef (static_funptr (ptr Args.t (* args *) @-> returning error))
        @@ _NS "Executable_SizeOfGeneratedCodeInBytes"
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

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Executable_Fingerprint"
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

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Executable_GetCostAnalysis"
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

      let api =
        typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Executable_GetCompiledMemoryStats"
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

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Executable_OutputDimensions"
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

      let api =
        typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Executable_OutputMemoryKinds"
    end

    module Serialize = struct
      let deleter = static_funptr (ptr serializedExecutable (* exec *) @-> returning void)

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

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Executable_Serialize"
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

      let api =
        typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Executable_DeserializeAndLoad"
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

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "LoadedExecutable_Destroy"
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

      let api =
        typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "LoadedExecutable_GetExecutable"
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

      let api =
        typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "LoadedExecutable_AddressableDevices"
    end

    module Delete = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "LoadedExecutable_Delete_Args"
        let executable = field t "executable" @@ ptr loadedExecutable
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "LoadedExecutable_Delete"
    end

    module IsDeleted = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "LoadedExecutable_IsDeleted_Args"
        let executable = field t "executable" @@ ptr loadedExecutable
        let is_deleted = field t "is_deleted" bool (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "LoadedExecutable_IsDeleted"
    end

    module Execute = struct
      let sendCallback =
        typedef
          (static_funptr
             (ptr Chunk.t (* chunk *) @-> ptr callbackError
             (* callback_error *) @-> size_t (* total_size_in_bytes *)
             @-> bool (* done *) @-> ptr void
             (* user_arg *) @-> returning error))
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

        (* Callbacks for when send/recv ops are executed. The outer lists correspond
           to each device returned by `PJRT_Executable_AddressableDevices` for
           `executable` (i.e. they will have length `num_devices`). Each inner list
           contains callback info for each send/recv op in `executable`; the order
           doesn't matter as the channel IDs are used instead. The callbacks can be
           stateful and the user code is responsible for managing state. The callback
           functions must outlive the execution (but not the info structs or lists). *)
        let send_callbacks = field t "send_callbacks" @@ ptr (ptr SendCallbackInfo.t)
        let recv_callbacks = field t "recv_callbacks" @@ ptr (ptr RecvCallbackInfo.t)
        let num_send_ops = field t "num_send_ops" size_t
        let num_recv_ops = field t "num_recv_ops" size_t

        (* If non-zero, identifies this execution as part of a potentially
           multi-device launch. This can be used to detect scheduling errors, e.g. if
           multi-host programs are launched in different orders on different hosts,
           the launch IDs may be used by the runtime to detect the mismatch. *)
        let launch_id = field t "launch_id" int

        (* A list of indices denoting the input buffers that should not be donated.
           An input buffer may be non-donable, for example, if it is referenced more
           than once. Since such runtime information is not available at compile time,
           the compiler might mark the input as `may-alias`, which could lead PjRt to
           donate the input buffer when it should not. By defining this list of
           indices, a higher-level PJRT caller can instruct PJRT client not to donate
           specific input buffers. The caller needs to make sure to keep it alive
           during the call. *)
        let non_donatable_input_indices = field t "non_donatable_input_indices" @@ ptr int64_t
        let num_non_donatable_input_indices = field t "num_non_donatable_input_indices" size_t

        let context =
          field t "context"
          @@ ptr executeContext (* Optional in some PJRT versions, corresponds to PJRT_ExecuteOptions.context *)

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

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "LoadedExecutable_Execute"
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

      let api =
        typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "LoadedExecutable_Fingerprint"
    end
  end

  module CopyDeviceStream = struct
    module Destroy = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "CopyToDeviceStream_Destroy_Args"
        let stream = field t "stream" @@ ptr copyToDeviceStream
        let () = seal t
      end

      (* Frees `stream`. `stream` can be nullptr. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "CopyToDeviceStream_Destroy"
    end

    module AddChunk = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "CopyToDeviceStream_AddChunk_Args"
        let stream = field t "stream" @@ ptr copyToDeviceStream

        (* Takes ownership of `chunk` (i.e. implementation will call chunk.deleter). *)
        let chunk = field t "chunk" @@ ptr Chunk.t
        let transfer_complete = field t "transfer_complete" @@ ptr event (* out *)
        let () = seal t
      end

      (* Emplaces a new chunk of data to copy to the device. The transfer is started
         immediately, and the returned event is triggered when the transfer completes
         or fails.

         The returned event will indicate an error if the chunk's size causes the
         amount of transferred data to exceed the total bytes, if the stream is
         already complete, or if the chunk is not a multiple of the granule size. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "CopyToDeviceStream_AddChunk"
    end

    module TotalBytes = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "CopyToDeviceStream_TotalBytes_Args"
        let stream = field t "stream" @@ ptr copyToDeviceStream
        let total_bytes = field t "total_bytes" int64_t (* out *)
        let () = seal t
      end

      (* Returns the total amount of data the stream expects to be transferred. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "CopyToDeviceStream_TotalBytes"
    end

    module GranuleSize = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) =
          pjrt_struct "CopyToDeviceStream_GranuleSize_Args"

        let stream = field t "stream" @@ ptr copyToDeviceStream
        let granule_size_in_bytes = field t "granule_size_in_bytes" int64_t (* out *)
        let () = seal t
      end

      (* Returns the granule size in bytes. The size of the chunk added to this stream
         must be a multiple of this number. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "CopyToDeviceStream_GranuleSize"
    end

    module CurrentBytes = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) =
          pjrt_struct "CopyToDeviceStream_CurrentBytes_Args"

        let stream = field t "stream" @@ ptr copyToDeviceStream
        let current_bytes = field t "current_bytes" int64_t (* out *)
        let () = seal t
      end

      (* Returns the amount of data the stream currently has either transferred or has
         buffered to transfer. *)
      module TopologyDescription = struct
        let serializedTopology : [ `SerializedTopology ] structure typ = snd @@ make_struct_base "SerializedTopology"

        module Create = struct
          module Args = struct
            type t

            let extension_start, struct_size, size, (t : t structure typ) =
              pjrt_struct "TopologyDescription_Create_Args"

            let topology_name = field t "topology_name" string
            let topology_name_size = field t "topology_name_size" size_t
            let create_options = field t "create_options" @@ ptr (const namedValue)
            let num_options = field t "num_options" size_t
            let topology = field t "topology" @@ ptr topologyDescription (* out *)
            let () = seal t
          end

          (* Creates and initializes a new PJRT_TopologyDescription and returns in `topology`. *)
          let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "TopologyDescription_Create"
        end

        module Destroy = struct
          module Args = struct
            type t

            let extension_start, struct_size, size, (t : t structure typ) =
              pjrt_struct "TopologyDescription_Destroy_Args"

            let topology = field t "topology" @@ ptr topologyDescription
            let () = seal t
          end

          (* Frees `topology`. `topology` can be nullptr. *)
          let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "TopologyDescription_Destroy"
        end

        module PlatformVersion = struct
          module Args = struct
            type t

            let extension_start, struct_size, size, (t : t structure typ) =
              pjrt_struct "TopologyDescription_PlatformVersion_Args"

            let topology = field t "topology" @@ ptr topologyDescription

            (* `platform_version` has the same lifetime as `topology`. It's owned by `topology`. *)
            let platform_version = field t "platform_version" string (* out *)
            let platform_version_size = field t "platform_version_size" size_t (* out *)
            let () = seal t
          end

          (* Returns a string containing human-readable, platform-specific version info
         (e.g. the CUDA version on GPU or libtpu version on Cloud TPU). *)
          let api =
            typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "TopologyDescription_PlatformVersion"
        end

        module PlatformName = struct
          module Args = struct
            type t

            let extension_start, struct_size, size, (t : t structure typ) =
              pjrt_struct "TopologyDescription_PlatformName_Args"

            let topology = field t "topology" @@ ptr (const topologyDescription)

            (* `platform_name` has the same lifetime as `topology`. It is owned by `topology`. *)
            let platform_name = field t "platform_name" string (* out *)
            let platform_name_size = field t "platform_name_size" size_t (* out *)
            let () = seal t
          end

          (* Returns a string that identifies the platform (e.g. "cpu", "gpu", "tpu"). *)
          let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "TopologyDescription_PlatformName"
        end

        module GetDeviceDescriptions = struct
          module Args = struct
            type t

            let extension_start, struct_size, size, (t : t structure typ) =
              pjrt_struct "TopologyDescription_GetDeviceDescriptions_Args"

            let topology = field t "topology" @@ ptr (const topologyDescription)

            (* Has the same lifetime as topology. *)
            let descriptions = field t "descriptions" @@ ptr (ptr (const deviceDescription)) (* out *)
            let num_descriptions = field t "num_descriptions" size_t (* out *)
            let () = seal t
          end

          (* Returns descriptions for all devices in this topology. The device
         descriptions can be returned in any order, but will be in the same order
         across calls within a process. *)
          let api =
            typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "TopologyDescription_GetDeviceDescriptions"
        end

        module Serialize = struct
          module Args = struct
            type t

            let extension_start, struct_size, size, (t : t structure typ) =
              pjrt_struct "TopologyDescription_Serialize_Args"

            let topology = field t "topology" @@ ptr topologyDescription

            (* Lives only as long as serialized_topology. *)
            let serialized_bytes = field t "serialized_bytes" string (* out *)
            let serialized_bytes_size = field t "serialized_bytes_size" size_t (* out *)
            let serialized_topology = field t "serialized_topology" @@ ptr serializedTopology (* out *)

            (* Must be called exactly once to free the backing memory for serialized_bytes. *)
            let serialized_topology_deleter =
              field t "serialized_topology_deleter" @@ static_funptr (ptr serializedTopology @-> returning void)
            (* out *)

            let () = seal t
          end

          (* Serializes the TopologyDescription to a string for use in cache keys. *)
          let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "TopologyDescription_Serialize"
        end

        module Attributes = struct
          module Args = struct
            type t

            let extension_start, struct_size, size, (t : t structure typ) =
              pjrt_struct "TopologyDescription_Attributes_Args"

            let topology = field t "topology" @@ ptr topologyDescription

            (* Only lives as long as topology. *)
            let attributes = field t "attributes" @@ ptr (const namedValue) (* out *)
            let num_attributes = field t "num_attributes" size_t (* out *)
            let () = seal t
          end

          (* Returns platform-specific topology attributes. *)
          let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "TopologyDescription_Attributes"
        end
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "CopyToDeviceStream_CurrentBytes"
    end
  end
end
