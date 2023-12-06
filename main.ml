let ffi_test () =
  let n = 10 in
  let foo = Array.init n Ffi_test.make_foo in
  let test = List.init n (fun i -> if Random.bool () then Ffi_test.create_foo i else Ffi_test.create_bar foo.(i)) in
  List.iter Ffi_test.print test;
  List.map Ffi_test.get_value test |> ignore

let ffi () =
  let rc = Ffi_test.init Ffi_test.version in
  assert (rc = 0);
  Ffi_test.log "Hello FFI";
  if true then ffi_test ();
  Ffi_test.uninit ()

let main () =
  Hello.print ();
  print_endline "World";
  ffi ()

let () = main ()
