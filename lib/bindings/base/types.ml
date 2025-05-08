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

module NamedValue = struct
  type t = String | Int64 | Int64List | Float | Bool

  let values = [ (String, "kString"); (Int64, "kInt64"); (Int64List, "kInt64List"); (Float, "kFloat"); (Bool, "kBool") ]
end

module Buffer_Type = struct
  type t =
    | INVALID
    | PRED
    | S8
    | S16
    | S32
    | S64
    | U8
    | U16
    | U32
    | U64
    | F16
    | F32
    | F64
    | BF16
    | C64
    | C128
    | F8E5M2
    | F8E4M3FN
    | F8E4M3B11FNUZ
    | F8E5M2FNUZ
    | F8E4M3FNUZ
    | S4
    | U4
    | TOKEN
    | S2
    | U2
    | F8E4M3
    | F8E3M4
    | F8E8M0FNU
    | F4E2M1FN

  let values =
    [
      (INVALID, "INVALID");
      (PRED, "PRED");
      (S8, "S8");
      (S16, "S16");
      (S32, "S32");
      (S64, "S64");
      (U8, "U8");
      (U16, "U16");
      (U32, "U32");
      (U64, "U64");
      (F16, "F16");
      (F32, "F32");
      (F64, "F64");
      (BF16, "BF16");
      (C64, "C64");
      (C128, "C128");
      (F8E5M2, "F8E5M2");
      (F8E4M3FN, "F8E4M3FN");
      (F8E4M3B11FNUZ, "F8E4M3B11FNUZ");
      (F8E5M2FNUZ, "F8E5M2FNUZ");
      (F8E4M3FNUZ, "F8E4M3FNUZ");
      (S4, "S4");
      (U4, "U4");
      (TOKEN, "TOKEN");
      (S2, "S2");
      (U2, "U2");
      (F8E4M3, "F8E4M3");
      (F8E3M4, "F8E3M4");
      (F8E8M0FNU, "F8E8M0FNU");
      (F4E2M1FN, "F4E2M1FN");
    ]
end

module HostBufferSemantics = struct
  type t = ImmutableOnlyDuringCall | ImmutableUntilTransferCompletes | ImmutableZeroCopy | MutableZeroCopy

  let values =
    [
      (ImmutableOnlyDuringCall, "kImmutableOnlyDuringCall");
      (ImmutableUntilTransferCompletes, "kImmutableUntilTransferCompletes");
      (ImmutableZeroCopy, "kImmutableZeroCopy");
      (MutableZeroCopy, "kMutableZeroCopy");
    ]
end

module Buffer_MemoryLayout_Type = struct
  type t = Tiled | Strides

  let values = [ (Tiled, "Tiled"); (Strides, "Strides") ]
end
