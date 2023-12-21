open Types

let scale = 1024

let directory_contents_raw p =
  Sys.readdir p
  |> Array.fold_left
       (fun a n ->
         if n = "." || n = ".." then a
         else
           let name = p ^ n in
           try
             let st = Unix.lstat name in
             let file = (Size.of_int ~scale st.st_size, inode_of_int st.st_ino, uid_of_int st.st_uid) in
             let files, dirs = a in
             match st.st_kind with
             | Unix.S_DIR -> (file :: files, (dev_of_int st.st_dev, name) :: dirs)
             | Unix.S_REG -> (file :: files, dirs)
             | _ -> a
           with Unix.Unix_error (Unix.EACCES, _, _) -> a)
       ([], [])

module InodeMap = Map.Make (Inode)
module InodeSet = Set.Make (Inode)
module UidMap = Map.Make (Uid)

type file = { inode : inode; size : Size.t }
type uid_files = uid * file list

let directory_contents p =
  let add_file m (size, inode, uid) =
    let old = UidMap.find_opt uid m |> Option.value ~default:[] in
    UidMap.add uid ({ inode; size } :: old) m
  in
  let files, dir = directory_contents_raw @@ p ^ "/" in
  let files = List.fold_left add_file UidMap.empty files in
  let files = UidMap.bindings files in
  (files, dir)

type dir = { dirs : dir list; files : uid_files list; name : string }

let all_directory_content p =
  let dev = dev_of_int @@ (Unix.stat p).st_dev in
  let rec get_dir name =
    if false then Printf.eprintf "dir:%s\n%!" name;
    let content = try Some (directory_contents name) with Sys_error _ -> None in
    Option.map
      (fun (files, dirs) ->
        let dirs =
          List.fold_left
            (fun dirs (dev_dir, dir) ->
              if dev_dir = dev then
                match get_dir dir with
                | Some { dirs = []; files = []; _ } -> dirs
                | Some dir -> dir :: dirs
                | None -> dirs
              else dirs)
            [] dirs
        in
        { name; files; dirs })
      content
  in
  get_dir p |> Option.get

let pp_files =
  Format.pp_print_list ~pp_sep:Format.pp_print_space (fun fmt (uid, files) ->
      Format.fprintf fmt "@[%a:%a@]" UInt.pp uid
        (Format.pp_print_list ~pp_sep:Format.pp_print_space (fun fmt { inode; size } ->
             Format.fprintf fmt "@[%a,%a@]" UInt.pp inode UInt.pp size))
        files)

let pp_dir =
  let rec pp_dir_aux fmt dir =
    Format.fprintf fmt "@[%s:Files:%a@ Dirs:%a@]" dir.name pp_files dir.files pp_dirs dir.dirs
  and pp_dirs fmt dirs = Format.pp_print_list ~pp_sep:Format.pp_print_newline pp_dir_aux fmt dirs in
  pp_dir_aux

let du_files files =
  let inodes = InodeSet.empty in
  Seq.fold_left
    (fun (inodes, uid_du) uids ->
      List.fold_left
        (fun (inodes, uid_du) (uid, files) ->
          let inodes, du =
            List.fold_left
              (fun (inodes, du) { inode; size } ->
                if InodeSet.mem inode inodes then (inodes, du)
                else
                  let inodes = InodeSet.add inode inodes in
                  let du = UInt.(du + size) in
                  (inodes, du))
              (inodes, UInt.of_int 0)
              files
          in
          (inodes, (uid, du) :: uid_du))
        (inodes, uid_du) uids)
    (inodes, []) files
  |> snd

let rec s_append s1 s2 () = match s1 () with Seq.Nil -> s2 () | Seq.Cons (x, next) -> Seq.Cons (x, s_append next s2)

let rec all_files dir =
  let top = Seq.return dir.files in
  List.fold_left (fun s dir -> s_append s @@ all_files dir) top dir.dirs

let du_users uids_size =
  List.fold_left
    (fun map (uid, size') ->
      let size = UidMap.find_opt uid map |> Option.value ~default:Int64.zero in
      let size = Int64.add size (UInt.to_int size' |> Int64.of_int) in
      UidMap.add uid size map)
    UidMap.empty uids_size
  |> UidMap.bindings

let du dir =
  all_files dir |> du_files |> du_users |> List.sort (fun (_, size_a) (_, size_b) -> Int64.compare size_b size_a)

let elapsed start =
  let now = Unix.gettimeofday () in
  now -. start

let profile ~name f a =
  let start = Unix.gettimeofday () in
  Printf.eprintf ">%s\n%!" name;
  let b = f a in
  Printf.eprintf ">%s (%.1f)\n%!" name (elapsed start);
  b

let do_du path =
  let dir = profile ~name:("SCAN" ^ " " ^ path) all_directory_content path in
  if false then Format.fprintf Format.std_formatter "@[%a@]\n%!" pp_dir dir
  else
    let uid_du = profile ~name:"DU" du dir in
    Format.fprintf Format.std_formatter "@[%a@]\n%!"
      (Format.pp_print_list ~pp_sep:Format.pp_print_newline (fun fmt (uid, size) ->
           Format.fprintf fmt "@[%a:@,%Lu@]" UInt.pp uid size))
      uid_du

let main () = if Array.length Sys.argv > 1 then Arg.parse_argv Sys.argv [] do_du "Disk usage" else do_du "/"
let _ = main ()
