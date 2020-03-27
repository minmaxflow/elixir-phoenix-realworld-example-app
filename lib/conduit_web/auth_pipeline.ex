defmodule ConduitWeb.AuthPipeLine do
  use Guardian.Plug.Pipeline,
    otp_app: :conduit,
    module: ConduitWeb.Guardian,
    error_handler: ConduitWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Token"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
