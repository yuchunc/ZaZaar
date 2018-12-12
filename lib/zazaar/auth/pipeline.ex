defmodule ZaZaar.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :zazaar,
    error_handler: Auth.ErrorHandler,
    module: Auth.Guardian

  plug(GPlug.VerifySession)
  plug(GPlug.LoadResource, allow_blank: true)
end
