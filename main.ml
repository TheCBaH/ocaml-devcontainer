let ffi_test () =
  let n = 10 in
  let foo = Array.init n Ffi_test.make_foo in
  let test = List.init n (fun i -> if Random.bool () then Ffi_test.create_foo i else Ffi_test.create_bar foo.(i)) in
  List.iter Ffi_test.print test;
  let sum = List.fold_left (fun s t -> s + Ffi_test.get_value t) 0 test in
  let sum_expected = n * (n - 1) / 2 in
  Printf.eprintf "%u %u\n%!" sum sum_expected;
  assert (sum = sum_expected);
  let to_caml = List.map Ffi_test.to_caml test in
  Format.fprintf Format.err_formatter "@[%a@]@\n%!"
    (Format.pp_print_list ~pp_sep:Format.pp_print_newline Test.pp)
    to_caml;
  let sum = List.fold_left (fun s t -> s + Test.get_value t) 0 to_caml in
  assert (sum = sum_expected);
  let of_caml = List.map Ffi_test.of_caml to_caml in
  let sum = List.fold_left (fun s t -> s + Ffi_test.get_value t) 0 test in
  assert (sum = sum_expected);
  List.iter Ffi_test.print of_caml

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
