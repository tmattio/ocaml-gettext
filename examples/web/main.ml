(** Main entry point for our application. *)

let set_locale handler req =
  let language =
    match Dream_accept.accepted_languages req |> List.hd with
    | Dream_accept.Language "" -> "en"
    | Dream_accept.Language s ->
        (* We're only interested in the "en" in "en-US" *)
        String.split_on_char '-' s |> List.hd
    | Dream_accept.Any -> "en"
  in
  Gettext.put_locale language;
  handler req

let () =
  Dream.run ~debug:true @@ Dream.logger @@ set_locale
  @@ Dream.router
       [ Dream.get "/" (fun _req -> Dream.html (I18n.s_ "Hello World!")) ]
  @@ Dream.not_found
