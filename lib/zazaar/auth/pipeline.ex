defmodule ZaZaar.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :zazaar,
    error_handler: ZaZaar.Auth.ErrorHandler,
    module: ZaZaar.Auth.Guardian

  plug(Guardian.Plug.VerifySession)
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end