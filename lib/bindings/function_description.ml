open Ctypes
open Pjrt_base.Type_description
module Types = Types_generated (* Module containing types generated from gpt2_type_description.ml *)

module Functions (F : Ctypes.FOREIGN) = struct
  open F
  open Types

  let dlopen = foreign (ns "dlopen") (ptr Dl.t @-> string @-> returning int)
  let dlclose = foreign (ns "dlclose") (ptr Dl.t @-> returning void)
end
