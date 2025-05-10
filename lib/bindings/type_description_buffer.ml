open Ctypes
open Pjrt_base.Type_description

module Types (F : Cstubs.Types.TYPE) = struct
  open Pjrt_base.Type_description.Base (F)
  open F

  let bufferType = make_enum "Buffer_Type" Pjrt_base.Types.Buffer_Type.values

  module Buffer = struct
    module Destroy = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_Destroy_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let () = seal t
      end

      (* Deletes the underlying runtime objects as if 'PJRT_Buffer_Delete' were
         called and frees `buffer`. `buffer` can be nullptr. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_Destroy"
    end

    module ElementType = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_ElementType_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let type_ = field t "type" bufferType (* out - PJRT_Buffer_Type* *)
        let () = seal t
      end

      (* Returns the type of the array elements of a buffer. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_ElementType"
    end

    module Dimensions = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_Dimensions_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let dims = field t "dims" @@ ptr int64_t (* out *)
        let num_dims = field t "num_dims" size_t (* out *)
        let () = seal t
      end

      (* Returns the array shape of `buffer`, i.e. the size of each dimension. *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_Dimensions"
    end

    module UnpaddedDimensions = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_UnpaddedDimensions_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let unpadded_dims = field t "unpadded_dims" @@ ptr int64_t (* out *)
        let num_dims = field t "num_dims" size_t (* out *)
        let () = seal t
      end

      (* Returns the unpadded array shape of `buffer`. This usually is equivalent to
         PJRT_Buffer_Dimensions, but for implementations that support
         dynamically-sized dimensions via padding to a fixed size, any dynamic
         dimensions may have a smaller unpadded size than the padded size reported by
         PJRT_Buffer_Dimensions. ("Dynamic" dimensions are those whose length is
         only known at runtime, vs. "static" dimensions whose size is fixed at compile
         time.) *)
      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_UnpaddedDimensions"
    end

    module DynamicDimensionIndices = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) =
          pjrt_struct "Buffer_DynamicDimensionIndices_Args"
        (* Returns the indices of dynamically-sized dimensions, or an empty list if all
         dimensions are static. ("Dynamic" dimensions are those whose length is
         only known at runtime, vs. "static" dimensions whose size is fixed at compile
         time.) *)

        let buffer = field t "buffer" @@ ptr buffer
        let dynamic_dim_indices = field t "dynamic_dim_indices" @@ ptr @@ const size_t (* out *)
        let num_dynamic_dims = field t "num_dynamic_dims" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_DynamicDimensionIndices"
    end
    (* DEPRECATED. Please use layout extension instead.
         https://github.com/openxla/xla/blob/main/xla/pjrt/c/pjrt_c_api_layouts_extension.h
         Returns the memory layout of the data in this buffer. *)

    module GetMemoryLayout = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_GetMemoryLayout_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let layout = field t "layout" @@ ptr bufferMemoryLayout (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_GetMemoryLayout"
    end

    module ToHostBuffer = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_ToHostBuffer_Args"
        let src = field t "src" @@ ptr buffer
        let dst = field t "dst" @@ ptr void
        let dst_size = field t "dst_size" size_t
        let event = field t "event" @@ ptr event (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_ToHostBuffer"
    end

    module OnDeviceSizeInBytes = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_OnDeviceSizeInBytes_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let on_device_size_in_bytes = field t "on_device_size_in_bytes" size_t (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_OnDeviceSizeInBytes"
    end

    module Delete = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_Delete_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_Delete"
    end

    module IsDeleted = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_IsDeleted_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let is_deleted = field t "is_deleted" bool (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_IsDeleted"
    end

    module CopyRawToHost = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_CopyRawToHost_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let dst = field t "dst" @@ ptr void
        let offset = field t "offset" int64_t
        let transfer_size = field t "transfer_size" @@ ptr event (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_CopyRawToHost"
    end

    module CopyToDevice = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_CopyToDevice_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let dst_device = field t "dst_device" @@ ptr device
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_CopyToDevice"
    end

    module CopyToMemory = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_CopyToMemory_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let dst_memory = field t "dst_memory" @@ ptr memory
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_CopyToMemory"
    end

    module IsOnCpu = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_IsOnCpu_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let is_on_cpu = field t "is_on_cpu" bool (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_IsOnCpu"
    end

    module Device = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_Device_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let device = field t "device" @@ ptr device (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_Device"
    end

    module Memory = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_Memory_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let memory = field t "memory" @@ ptr memory (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_Memory"
    end

    module ReadyEvent = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_ReadyEvent_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let event = field t "event" @@ ptr event (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_ReadyEvent"
    end

    module UnsafePointer = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_UnsafePointer_Args"
        let buffer = field t "buffer" @@ ptr buffer
        let buffer_pointer = field t "buffer_pointer" @@ ptr void (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_UnsafePointer"
    end

    module IncreaseExternalReferenceCount = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) =
          pjrt_struct "Buffer_IncreaseExternalReferenceCount_Args"

        let buffer = field t "buffer" @@ ptr buffer
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_IncreaseExternalReferenceCount"
    end

    module DecreaseExternalReferenceCount = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) =
          pjrt_struct "Buffer_DecreaseExternalReferenceCount_Args"

        let buffer = field t "buffer" @@ ptr buffer
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_DecreaseExternalReferenceCount"
    end

    module OpaqueDeviceMemoryDataPointer = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) =
          pjrt_struct "Buffer_OpaqueDeviceMemoryDataPointer_Args"

        let buffer = field t "buffer" @@ ptr buffer
        let device_memory_ptr = field t "device_memory_ptr" @@ ptr void (* out *)
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Buffer_OpaqueDeviceMemoryDataPointer"
    end
  end

  let hostBufferSemantics = make_enum "HostBufferSemantics" Pjrt_base.Types.HostBufferSemantics.values

  module BufferFromHostBuffer = struct
    module Args = struct
      type t

      let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_BufferFromHostBuffer_Args"
      let client = field t "client" @@ ptr client

      (* Pointer to the host buffer *)
      let data = field t "data" @@ ptr void

      (* The type of the `data`, and the type of the resulting output `buffer` *)
      let type_ = field t "type" bufferType

      (* The array dimensions of `data`. *)
      let dims = field t "dims" @@ ptr int64_t
      let num_dims = field t "num_dims" size_t

      (* Number of bytes to traverse per dimension of the input data. Must be the
           same size as `dims`, or empty. If empty, the array is assumed to have a
           dense layout with dimensions in major-to-minor order
           Caution: `byte_strides` are allowed to be negative, in which case `data`
           may need to point to the interior of the buffer, not necessarily its start. *)
      let byte_strides = field t "byte_strides" @@ ptr int64_t
      let num_byte_strides = field t "num_byte_strides" size_t
      let host_buffer_semantics = field t "host_buffer_semantics" hostBufferSemantics

      (* Device to copy host data to. *)
      let device = field t "device" @@ ptr device

      (* If nullptr, host data will be copied to `device`, otherwise we copy data to
           `memory`. *)
      let memory = field t "memory" @@ ptr memory (* optional *)

      (* The caller is responsible to keep the data (tiled or strides) in the
           device_layout alive during the call. If nullptr, the device layout is
           assumed to be a dense layout with dimensions in major-to-minor order. *)
      let device_layout = field t "device_layout" @@ ptr bufferMemoryLayout

      (* Event indicating when it's safe to free `data`. The caller is responsible
           for calling PJRT_Event_Destroy. *)
      let done_with_host_buffer = field t "done_with_host_buffer" @@ ptr event (* out *)

      (* Output device buffer. The caller is responsible for calling
           PJRT_Buffer_Destroy. *)
      let buffer = field t "buffer" @@ ptr buffer (* out *)
      let () = seal t
    end

    (* Asynchronously copies a buffer stored on host to device memory. *)
    let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_BufferFromHostBuffer"
  end

  module CreateViewOfDeviceBuffer = struct
    module Args = struct
      type t

      let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_CreateViewOfDeviceBuffer_Args"
      let client = field t "client" @@ ptr client

      (* A pointer to a non-owned device buffer. A PJRT_Buffer that is a non-owned
           view of this device buffer will be created. *)
      let device_buffer_ptr = field t "device_buffer_ptr" @@ ptr void
      let dims = field t "dims" @@ ptr int64_t
      let num_dims = field t "num_dims" size_t
      let element_type = field t "element_type" bufferType
      let layout = field t "layout" @@ ptr bufferMemoryLayout

      (* The device that `device_buffer_ptr` is on. The argument is ignored if
           `memory` is provided.
           DEPRECATED: Use `memory` instead. *)
      let device = field t "device" @@ ptr device

      (* A callback to be performed when the PJRT_Buffer is done with the on-device
           buffer. This callback is optional and can be a nullptr. *)
      let on_delete_callback =
        field t "on_delete_callback"
        @@ static_funptr (ptr void (* device_buffer_ptr *) @-> ptr void (* user_arg *) @-> returning void)

      (* `on_delete_callback_arg` will be passed to `on_delete_callback` as
           `user_arg` argument. *)
      let on_delete_callback_arg = field t "on_delete_callback_arg" @@ ptr void

      (* A platform-specific stream handle that should contain the work or events
           needed to materialize the on-device buffer. It is optional and can be
           casted from a nullptr. PJRT_Client_CreateViewOfDeviceBuffer_Args will
           append an event to `stream` that indicates when the returned buffer is
           ready to use. This is intended to support dlpack on GPU and is not expected
           to be supported on all hardware platforms. *)
      let stream = field t "stream" intptr_t

      (* Output buffer. The caller is responsible for calling PJRT_Buffer_Destroy. *)
      let buffer = field t "buffer" @@ ptr buffer (* out *)

      (* The memory space that `device_buffer_ptr` is in. *)
      let memory = field t "memory" @@ ptr memory
      let () = seal t
    end

    (* Creates a PJRT buffer that is a non-owned view of an on-device buffer
         (typically allocated by another library). The buffer may be mutated,
         for example, if the buffer is donated to an Execute operation. This method is
         not required on all hardware platforms. *)
    let api =
      typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_CreateViewOfDeviceBuffer"
  end

  module Executable_OutputElementTypes = struct
    module Args = struct
      type t

      let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Executable_OutputElementTypes_Args"
      let executable = field t "executable" @@ ptr executable
      let output_types = field t "output_types" @@ ptr bufferType (* out  *)
      let num_output_types = field t "num_output_types" size_t (* out *)
      let () = seal t
    end

    let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Executable_OutputElementTypes"
  end
end
