defmodule ConduitWeb.AuthOptPipeLine do
  use Guardian.Plug.Pipeline,
    otp_app: :conduit,
    module: ConduitWeb.Guardian,
    error_handler: ConduitWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Token"
  plug Guardian.Plug.LoadResource, allow_blank: true
end
