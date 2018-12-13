defmodule ZaZaar.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :zazaar,
    error_handler: Auth.ErrorHandler,
    module: Auth.Guardian

  plug(Guardian.Plug.VerifySession)
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
