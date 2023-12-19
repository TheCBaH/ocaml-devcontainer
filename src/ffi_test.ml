let version = 1

type test
type test_bar
type foo = { a : int }
type bar = { foo : foo }

external init : int -> int = "caml_test_init"
external c_uninit : unit -> unit = "caml_test_uninit"

let uninit () =
  Gc.major ();
  c_uninit ()

external log : string -> unit = "caml_test_log"
external create_foo : int -> test = "caml_create_foo"
external get_value : test -> int = "caml_test_get_value"
external print : test -> unit = "caml_test_print"
external make_foo : int -> test_bar = "caml_make_foo"
external create_bar : test_bar -> test = "caml_create_bar"

let of_caml t = match t with Test.Bar bar -> create_bar @@ make_foo bar.a | Test.Foo a -> create_foo a

external to_caml : test -> Test.t = "caml_test_to_caml"
