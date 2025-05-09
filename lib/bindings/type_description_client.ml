open Ctypes
open Pjrt_base.Type_description

module Types (F : Cstubs.Types.TYPE) = struct
  open Pjrt_base.Type_description.Base (F)
  open F

  let asyncHostToDeviceTransferManager : [ `AsyncHostToDeviceTransferManager ] structure typ =
    snd @@ make_struct_base "AsyncHostToDeviceTransferManager"

  let bufferMemoryLayoutTiled : [ `Buffer_MemoryLayout_Tiled ] structure typ =
    snd @@ make_struct_base "Buffer_MemoryLayout_Tiled"

  (* A map from physical dimension numbers to logical dimension numbers.
     The first element is the most minor physical dimension (fastest varying
     index) and the last the most major (slowest varying index). The contents of
     the vector are the indices of the *logical* dimensions in the shape. Must
     be the same size as the number of dimensions of the buffer. *)
  module Buffer_MemoryLayout_Tiled = struct
    type t = [ `Buffer_MemoryLayout_Tiled ]

    let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_MemoryLayout_Tiled"
    let minor_to_major = field t "minor_to_major" @@ ptr int64_t
    let minor_to_major_size = field t "minor_to_major_size" size_t

    (* A concatenated list of tile dimensions. *)
    let tile_dims = field t "tile_dims" @@ ptr int64_t

    (* The list of tile dimension sizes. The size of this list is `num_tiles`. *)
    let tile_dim_sizes = field t "tile_dim_sizes" @@ ptr size_t
    let num_tiles = field t "num_tiles" size_t
    let () = seal t
  end

  let bufferMemoryLayoutStrides : [ `Buffer_MemoryLayout_Strides ] structure typ =
    snd @@ make_struct_base "Buffer_MemoryLayout_Strides"

  module Buffer_MemoryLayout_Strides = struct
    type t = [ `Buffer_MemoryLayout_Strides ]

    let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_MemoryLayout_Strides"

    (* Number of bytes to traverse per dimension. Must be the same size as
       the number of dimensions of the data. Caution: `byte_strides` are allowed
       to be negative, in which case data may need to point to the interior of
       the buffer, not necessarily its start. *)
    let byte_strides = field t "byte_strides" @@ ptr int64_t
    let num_byte_strides = field t "num_byte_strides" size_t
    let () = seal t
  end

  let bufferMemoryLayoutType = make_enum "Buffer_MemoryLayout_Type" Pjrt_base.Types.Buffer_MemoryLayout_Type.values
  let bufferType = make_enum "Buffer_Type" Pjrt_base.Types.Buffer_Type.values
  let hostBufferSemantics = make_enum "HostBufferSemantics" Pjrt_base.Types.HostBufferSemantics.values
  let bufferMemoryLayout : [ `Buffer_MemoryLayout ] structure typ = snd @@ make_struct_base "Buffer_MemoryLayout"

  (* Describe the memory layout. It can be (1) a list of minor-to-major order and
     optional tilings (each tile is a list of dimensions), or (2) a list of
     strides. *)
  module Buffer_MemoryLayout = struct
    type t = [ `BufferMemoryLayout ]

    let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Buffer_MemoryLayout"
    let tiled = field t "tiled" bufferMemoryLayoutTiled
    let strides = field t "strides" bufferMemoryLayoutStrides
    let type_ = field t "type" bufferMemoryLayoutType
    let () = seal t
  end

  (* A callback to delete the value returned by PJRT_KeyValueGetCallback.  *)
  let keyValueGetCallback_ValueDeleter =
    typedef (static_funptr (ptr char (* value *) @-> returning void)) @@ _NS "KeyValueGetCallback_ValueDeleter"

  module KeyValueGetCallback = struct
    module Args = struct
      type t

      let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "KeyValueGetCallback_Args"
      let key = field t "key" string
      let key_size = field t "key_size" size_t
      let timeout_in_ms = field t "timeout_in_ms" int
      let callback_error = field t "callback_error" @@ ptr callbackError
      let user_arg = field t "user_arg" @@ ptr void
      let value_ = field t "value" @@ ptr char (* out *)
      let value_size = field t "value_size" size_t (* out *)
      let value_deleter_callback = field t "value_deleter_callback" keyValueGetCallback_ValueDeleter (* out *)
      let () = seal t
    end

    (* Requirements for PJRT_KeyValueGetCallback implementation: (1) Thread-safe.
       (2) The caller that provides the two callbacks is responsible for avoiding
       key collisions between different users of key-value store (i.e. between
       different plugins, but not between different nodes in one plugin). (3)
       Blocking. *)
    let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "KeyValueGetCallback"
  end

  module KeyValueTryGetCallback = struct
    module Args = struct
      type t

      let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "KeyValueTryGetCallback_Args"
      let key = field t "key" string
      let key_size = field t "key_size" size_t
      let user_arg = field t "user_arg" @@ ptr void
      let callback_error = field t "callback_error" @@ ptr callbackError
      let value_ = field t "value" @@ ptr char (* out *)
      let value_size = field t "value_size" size_t (* out *)
      let value_deleter_callback = field t "value_deleter_callback" keyValueGetCallback_ValueDeleter
      let () = seal t
    end

    (* Returns true if this PJRT_Event has completed, including if an error has
       occurred. *)
    let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "KeyValueTryGetCallback"
  end

  module KeyValuePutCallback = struct
    module Args = struct
      type t

      let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "KeyValuePutCallback_Args"
      let key = field t "key" string
      let key_size = field t "key_size" size_t

      (* Only needs to stay alive for the duration of the PJRT_KeyValuePutCallback
         call. *)
      let value_ = field t "value" string
      let value_size = field t "value_size" size_t
      let callback_error = field t "callback_error" @@ ptr callbackError
      let user_arg = field t "user_arg" @@ ptr void
      let () = seal t
    end

    (* Requirements for PJRT_KeyValuePutCallback implementation: (1) Thread-safe.
       (2) The caller that provides the two callbacks is responsible for avoiding
       key collisions between different users of key-value store (i.e. between
       different plugins, but not between different nodes in one plugin). *)
    let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "KeyValuePutCallback"
  end

  let program : [ `Program ] structure typ = snd @@ make_struct_base "Program"

  module Client = struct
    module Create = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_Create_Args"

        (* Extra platform-specific options to create a client. *)
        let create_options = field t "create_options" @@ ptr void
        let num_options = field t "num_options" size_t (* num_options in C *)

        (* Key-value get/put callback provided by the caller of PJRT_Client_Create. *)
        (* PJRT client can use these callbacks to share information between *)
        (* processes/nodes. *)
        let kv_get_callback = field t "kv_get_callback" KeyValueGetCallback.api

        (* Will be passed to `kv_get_callback` as `user_arg` argument. *)
        let kv_get_user_arg = field t "kv_get_user_arg" (ptr void)
        let kv_put_callback = field t "kv_put_callback" KeyValuePutCallback.api

        (* Will be passed to `kv_put_callback` as `user_arg` argument. *)
        let kv_put_user_arg = field t "kv_put_user_arg" (ptr void)

        (* Key-value try-get callback provided by the caller of PJRT_Client_Create. *)
        (* Same as key-value get callback, but returns `NotFoundError` immediately if *)
        (* the key is not found. *)
        let kv_try_get_callback = field t "kv_try_get_callback" KeyValueTryGetCallback.api

        (* Will be passed to `kv_try_get_callback` as `user_arg` argument. *)
        let kv_try_get_user_arg = field t "kv_try_get_user_arg" (ptr void)
        let client = field t "client" @@ ptr client (* out *)
        let () = seal t
      end

      (* Creates a new PJRT_Client instance. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_Create"
    end

    module Destroy = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_Destroy_Args"
        let client = field t "client" @@ ptr client
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_Destroy"
    end

    module PlatformName = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_PlatformName_Args"
        let client = field t "client" @@ ptr client

        (* `platform_name` has the same lifetime as `client`. It is owned by `client`. *)
        let platform_name = field t "platform_name" string (* out *)
        let platform_name_size = field t "platform_name_size" size_t (* out *)
        let () = seal t
      end

      (* Returns a string that identifies the platform (e.g. "cpu", "gpu", "tpu"). *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_PlatformName"
    end

    module ProcessIndex = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_ProcessIndex_Args"
        let client = field t "client" @@ ptr client
        let process_index = field t "process_index" int (* out *)
        let () = seal t
      end

      (* Return the process index of this client. Always 0 in single-process
     settings. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_ProcessIndex"
    end

    module PlatformVersion = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_PlatformVersion_Args"
        let client = field t "client" @@ ptr client

        (* `platform_version` has the same lifetime as `client`. It's owned by
       `client`. *)
        let platform_version = field t "platform_version" string (* out *)
        let platform_version_size = field t "platform_version_size" size_t (* out *)
        let () = seal t
      end

      (* Returns a string containing human-readable, platform-specific version info
     (e.g. the CUDA version on GPU or libtpu version on Cloud TPU). *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_PlatformVersion"
    end

    module TopologyDescription = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_TopologyDescription_Args"
        let client = field t "client" @@ ptr client

        (* Is owned by and has the same lifetime as `client`. *)
        let topology = field t "topology" @@ ptr topologyDescription (* out *)
        let () = seal t
      end

      (* Returns the topology description of the runtime topology. The returned
     topology is owned by the client and should not be deleted by the caller. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_TopologyDescription"
    end

    module Devices = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_Devices_Args"
        let client = field t "client" @@ ptr client
        let devices = field t "devices" @@ ptr (ptr device) (* out *)
        let num_devices = field t "num_devices" size_t (* out *)
        let () = seal t
      end

      (* Returns a list of all devices visible to the runtime, including addressable
     and non-addressable devices. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_Devices"
    end

    module AddressableDevices = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_AddressableDevices_Args"
        let client = field t "client" @@ ptr client
        let addressable_devices = field t "addressable_devices" @@ ptr (ptr device) (* out *)
        let num_addressable_devices = field t "num_addressable_devices" size_t (* out *)
        let () = seal t
      end

      (* Returns a list of devices that are addressable from the client.
     Addressable devices are those that the client can issue commands to.
     All devices are addressable in a single-process environment. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_AddressableDevices"
    end

    module LookupDevice = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_LookupDevice_Args"
        let client = field t "client" @@ ptr client
        let id = field t "id" int

        (* `device` has the same lifetime as `client`. It is owned by `client`. *)
        let device = field t "device" @@ ptr device (* out *)
        let () = seal t
      end

      (* Returns a PJRT_Device* with the specified ID as returned by
     PJRT_DeviceDescription_Id. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_LookupDevice"
    end

    module LookupAddressableDevice = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) =
          pjrt_struct "Client_LookupAddressableDevice_Args"

        let client = field t "client" @@ ptr client
        let local_hardware_id = field t "local_hardware_id" int

        (* `addressable_device` has the same lifetime as `client`. It is owned by
       `client`. *)
        let addressable_device = field t "addressable_device" @@ ptr device (* out *)
        let () = seal t
      end

      (* Returns a PJRT_Device* with the specified local hardware ID as returned by
     PJRT_Device_LocalHardwareId. *)
      let api =
        typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_LookupAddressableDevice"
    end

    module AddressableMemories = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_AddressableMemories_Args"
        let client = field t "client" @@ ptr client
        let addressable_memories = field t "addressable_memories" @@ ptr (ptr memory) (* out *)
        let num_addressable_memories = field t "num_addressable_memories" size_t (* out *)
        let () = seal t
      end

      (* Returns a list of memories that are addressable from the client. Addressable
     memories are those that the client can directly transfer data to and from.
     All memories are addressable in a single-process environment. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_AddressableMemories"
    end

    module Compile = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_Compile_Args"
        let client = field t "client" @@ ptr client

        (* Only needs to stay alive for the duration of the Compile call.
       `program->format` and `program->format_size` are owned by the caller. *)
        let program = field t "program" @@ ptr program

        (* TODO(b/240560013): consider putting some of option fields in priv.
       Serialized CompileOptionsProto
       (https://github.com/tensorflow/tensorflow/blob/master/tensorflow/compiler/xla/pjrt/compile_options.proto) *)
        let compile_options = field t "compile_options" string
        let compile_options_size = field t "compile_options_size" size_t
        let executable = field t "executable" @@ ptr loadedExecutable (* out *)
        let () = seal t
      end

      (* Compiles a program in specified format (such as MLIR or HLO) with given
     `options`. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_Compile"
    end

    module DefaultDeviceAssignment = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) =
          pjrt_struct "Client_DefaultDeviceAssignment_Args"

        let client = field t "client" @@ ptr client
        let num_replicas = field t "num_replicas" int
        let num_partitions = field t "num_partitions" int

        (* Must be greater than or equal to `num_replicas * num_partitions` *)
        let default_assignment_size = field t "default_assignment_size" size_t

        (* Points to an array of size `default_assignment_size`.
       This API writes `num_replicas * num_partitions` ints within that buffer.
       The caller retains ownership of this memory. *)
        let default_assignment = field t "default_assignment" @@ ptr int (* in/out *)
        let () = seal t
      end

      let api =
        typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_DefaultDeviceAssignment"
    end

    module DmaMap = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_DmaMap_Args"
        let client = field t "client" @@ ptr client
        let data = field t "data" @@ ptr void
        let size_ = field t "size" size_t
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_DmaMap"
    end

    module DmaUnmap = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_DmaUnmap_Args"
        let client = field t "client" @@ ptr client
        let data = field t "data" @@ ptr void
        let () = seal t
      end

      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Client_DmaUnmap"
    end

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

        let extension_start, struct_size, size, (t : t structure typ) =
          pjrt_struct "Client_CreateViewOfDeviceBuffer_Args"

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

    module CreateBuffersForAsyncHostToDevice = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) =
          pjrt_struct "Client_CreateBuffersForAsyncHostToDevice_Args"

        let client = field t "client" @@ ptr client
        let shape_specs = field t "shape_specs" @@ ptr shapeSpec
        let num_shape_specs = field t "num_shape_specs" size_t
        let device_layouts = field t "device_layouts" @@ ptr (ptr bufferMemoryLayout) (* optional *)
        let num_device_layouts = field t "num_device_layouts" size_t
        let memory = field t "memory" @@ ptr memory
        let transfer_manager = field t "transfer_manager" @@ ptr asyncHostToDeviceTransferManager (* out *)
        let () = seal t
      end

      let api =
        typedef (static_funptr (ptr Args.t (* args *) @-> returning error))
        @@ _NS "Client_CreateBuffersForAsyncHostToDevice"
    end
  end
end
