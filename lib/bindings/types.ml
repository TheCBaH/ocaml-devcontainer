module Extension_Type = struct
  type t =
    | Gpu_Custom_Call
    | Profiler
    | Custom_Partitioner
    | Stream
    | Layouts
    | FFI
    | MemoryDescriptions
    | Triton
    | RawBuffer (* Experimental. *)

  let values =
    [
      (Gpu_Custom_Call, "Gpu_Custom_Call");
      (Profiler, "Profiler");
      (Custom_Partitioner, "Custom_Partitioner");
      (Stream, "Stream");
      (Layouts, "Layouts");
      (FFI, "FFI");
      (MemoryDescriptions, "MemoryDescriptions");
      (Triton, "Triton");
      (RawBuffer, "RawBuffer");
    ]
end

(* Codes are based on https://abseil.io/docs/cpp/guides/status-codes *)
module Error_Code = struct
  type t =
    | CANCELLED
    | UNKNOWN
    | INVALID_ARGUMENT
    | DEADLINE_EXCEEDED
    | NOT_FOUND
    | ALREADY_EXISTS
    | PERMISSION_DENIED
    | RESOURCE_EXHAUSTED
    | FAILED_PRECONDITION
    | ABORTED
    | OUT_OF_RANGE
    | UNIMPLEMENTED
    | INTERNAL
    | UNAVAILABLE
    | DATA_LOSS
    | UNAUTHENTICATED

  let values =
    [
      (CANCELLED, "CANCELLED");
      (UNKNOWN, "UNKNOWN");
      (INVALID_ARGUMENT, "INVALID_ARGUMENT");
      (DEADLINE_EXCEEDED, "DEADLINE_EXCEEDED");
      (NOT_FOUND, "NOT_FOUND");
      (ALREADY_EXISTS, "ALREADY_EXISTS");
      (PERMISSION_DENIED, "PERMISSION_DENIED");
      (RESOURCE_EXHAUSTED, "RESOURCE_EXHAUSTED");
      (FAILED_PRECONDITION, "FAILED_PRECONDITION");
      (ABORTED, "ABORTED");
      (OUT_OF_RANGE, "OUT_OF_RANGE");
      (UNIMPLEMENTED, "UNIMPLEMENTED");
      (INTERNAL, "INTERNAL");
      (UNAVAILABLE, "UNAVAILABLE");
      (DATA_LOSS, "DATA_LOSS");
      (UNAUTHENTICATED, "UNAUTHENTICATED");
    ]
end
