module Default =
(val Gettext.create ~failsafe:RaiseException
       ~path:[ "_build/default/examples/web/gettext" ]
       ~categories:[ (LC_MESSAGES, "en"); (LC_MESSAGES, "fr") ]
       ~language:"en" ~codeset:"UTF-8" ~realize:GettextCamomile.Map.realize
       "default")

include Default
