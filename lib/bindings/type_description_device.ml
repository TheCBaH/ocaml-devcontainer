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
end
