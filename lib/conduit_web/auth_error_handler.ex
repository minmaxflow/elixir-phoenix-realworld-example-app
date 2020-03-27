defmodule ConduitWeb.AuthErrorHandler do
  @behaviour Guardian.Plug.ErrorHandler

  import Phoenix.Controller
  import Plug.Conn

  alias ConduitWeb.ErrorView

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> put_view(ErrorView)
    |> render(:"401")
  end
end
