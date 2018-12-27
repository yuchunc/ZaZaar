defmodule ZaZaar.Auth.UserPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :zazaar,
    error_handler: ZaZaar.Auth.UserErrorHandler,
    module: ZaZaar.Auth.Guardian

  plug Guardian.Plug.VerifySession, key: :user
end
