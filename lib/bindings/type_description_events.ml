open Ctypes
open Pjrt_base.Type_description

module Types (F : Cstubs.Types.TYPE) = struct
  open Pjrt_base.Type_description.Base (F)
  open F
  (* ---------------------------------- Events ----------------------------------- *)

  (* Represents a notifying event that is returned by PJRT APIs that enqueue
     asynchronous work, informing callers when the work is complete and reporting
     a value of type `PJRT_Error*` or `nullptr` as error status.

     Callers are always responsible for freeing `PJRT_Event`s by calling
     `PJRT_Event_Destroy`. *)
  module Event = struct
    type t

    let _struct : t structure typ = F.structure @@ _NS "Event"
    let t = ptr @@ typedef _struct @@ ns "Event"

    module Destroy = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Event_Destroy_Args"
        let event = field t "event" t
        let () = seal t
      end

      (* Frees `event`. `event` can be `nullptr`. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Event_Destroy"
    end

    module IsReady = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Event_IsReady_Args"
        let event = field t "event" t
        let is_ready = field t "is_ready" bool (* out *)
        let () = seal t
      end

      (* Returns true if this PJRT_Event has completed, including if an error has
       occurred. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Event_IsReady"
    end

    module Error = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Event_Error_Args"
        let event = field t "event" t
        let () = seal t
      end

      (* Should only be called if PJRT_Event_IsReady returns true.
       Returns `nullptr` if there is no error.
       The returned error should be freed with `PJRT_Error_Destroy`.

       If `PJRT_Event_Await` has been called, this will return a pointer to an
       identical error status as that call, as will subsequent calls to
       `PJRT_Event_Error`. However, each of these `PJRT_Error *` pointers are
       independent of `PJRT_Error *`s returned by other function calls, so they must
       each be freed separately using `PJRT_Error_Destroy`. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Event_Error"
    end

    module Await = struct
      module Args = struct
        type t

        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Event_Await_Args"
        let event = field t "event" t
        let () = seal t
      end

      (* Blocks the calling thread until `event` is ready, then returns the error
       status (with `nullptr` indicating no error). The returned status should be
       freed with `PJRT_Error_Destroy`. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Event_Await"
    end

    (* A callback to be performed once an event is ready. It will be called on the
       event's error state and a pointer to an object of the caller's choice.
       Ownership of `error` is passed to the callback. The callback must destroy
       `error` via `PJRT_Error_Destroy`. The caller retains ownership of `user_arg`. *)
    let onReadyCallback =
      typedef (static_funptr (error (* error *) @-> ptr void (* user_arg *) @-> returning void))
      @@ ns "Event_OnReadyCallback"

    module OnReady = struct
      module Args = struct
        type t

        let event = t
        let extension_start, struct_size, size, (t : t structure typ) = pjrt_struct "Event_OnReady_Args"
        let event = field t "event" event
        let callback = field t "callback_" onReadyCallback

        (* `user_arg` allows `callback` to be called with arbitrary arguments (e.g.
         via pointers in a struct cast to void* ). *)
        let user_arg = field t "user_arg" (ptr void)
        let () = seal t
      end

      (* Registers `callback` to be called once `event` is ready, with `event`'s
       error status and a pointer to an object of the caller's choice as arguments. *)
      let api = typedef (static_funptr (ptr Args.t (* args *) @-> returning error)) @@ _NS "Event_OnReady"
    end
  end
end
