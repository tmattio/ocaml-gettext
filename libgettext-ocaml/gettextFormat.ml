(** Implements functions helping check that two strings are equivalent, regarding printf use *)

open GettextTypes;;
open GettextUtils;;

exception FormatInconsistent of string * string;;

let string_of_exception exc =
  match exc with
    FormatInconsistent (s1,s2) ->
      Printf.sprintf "Strings %S and %S doesn't use the same printf format" s1 s2
  | _ ->
      ""
;;

(** check_format failsafe translation : returns a translation structure
    if all the string contained in the translation are equivalent of
    str_id, regarding printf format. If not, replace each string which conflict
    by str_id, in the result *)
let check_format failsafe translation = 
  let format_lst_of_string str =
    let lexbuf = Lexing.from_string str
    in
    GettextFormat_parser.main GettextFormat_lexer.token lexbuf 
  in
  (* return true in case of problem *)
  let check_format_lst_lst lst1 lst2 = 
    let check_format_lst_lst_aux b s1 s2 =
      b || (String.compare s1 s2 <> 0)
    in
    try
      List.fold_left2 check_format_lst_lst_aux false lst1 lst2
    with Invalid_argument _->
      true
  in
  let check_format_lst_str lst str =
    check_format_lst_lst lst (format_lst_of_string str)
  in
  let choose_format lst_ref str_ref str =
    if check_format_lst_str lst_ref str then
      fail_or_continue failsafe 
      string_of_exception 
      (FormatInconsistent(str,str_ref))
      str_ref
    else
      str
  in
  match translation with
    Singular (str_id,str) ->
      let lst_id = format_lst_of_string str_id
      in
      Singular(str_id,choose_format lst_id str_id str)
  | Plural (str_id,str_plural,lst) ->
      let lst_id = format_lst_of_string str_id
      in
      let valid_str_plural = choose_format lst_id str_id str_plural
      in
      let valid_lst = 
        match lst with
          trans_singular :: trans_plurals ->
            (choose_format lst_id str_id trans_singular) :: 
              (List.map (choose_format lst_id valid_str_plural) trans_plurals)
        | [] ->
            []
      in
      Plural(str_id, valid_str_plural, valid_lst)
;;