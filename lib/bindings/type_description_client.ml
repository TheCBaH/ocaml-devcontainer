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
    let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "KeyValueGetCallback"
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
    let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "KeyValueTryGetCallback"
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
    let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "KeyValuePutCallback"
  end

  module ClientCreate = struct
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
    let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Client_Create"
  end

  module Client_Destroy = struct
    module Args = struct
      type t

      let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Client_Destroy_Args"
      let client = field t "client" @@ ptr client
      let () = seal t
    end

    let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Client_Destroy"
  end

  module Client_PlatformName = struct
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
    let api = typedef (static_funptr (ptr Args.t @-> returning error)) @@ _NS "Client_PlatformName"
  end
end
