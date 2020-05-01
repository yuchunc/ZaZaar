defmodule ZaZaar.Auth.PagePipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :zazaar,
    error_handler: ZaZaar.Auth.PageErrorHandler,
    key: :page

  plug Guardian.Plug.VerifySession
end
