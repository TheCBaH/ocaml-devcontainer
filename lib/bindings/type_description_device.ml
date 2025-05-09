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
end
