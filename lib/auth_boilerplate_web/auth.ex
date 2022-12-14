defmodule AuthBoilerplateWeb.Auth do
  import Plug.Conn

  alias AuthBoilerplate.Auth

  def get_token(user) do
    Auth.generate_user_session_token(user)
  end

  def delete_token(token) do
    Auth.delete_session_token(token)
  end

  @doc """
  Authenticates the user by looking into the session
  and remember me token.
  """

  def fetch_current_user(conn, _opts) do
      token = fetch_token(get_req_header(conn, "authorization"))
      user = token && Auth.get_user_by_session_token(token)
      assign(conn, :current_user, user)
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """

  def require_guest_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> put_status(401)
      |> Phoenix.Controller.put_view(AuthBoilerplateWeb.ErrorView)
      |> Phoenix.Controller.render(:"401")
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.
  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] != nil do
      conn
    else
      conn
      |> put_status(401)
      |> Phoenix.Controller.put_view(AuthBoilerplateWeb.ErrorView)
      |> Phoenix.Controller.render(:"401")
      |> halt()
    end
  end

  defp fetch_token([]), do: nil

  defp fetch_token([token | _tail]) do
    token
    |> String.replace("Token", "")
    |> String.trim()
  end

end
