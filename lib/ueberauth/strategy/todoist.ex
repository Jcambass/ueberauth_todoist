defmodule Ueberauth.Strategy.Todoist do
  @moduledoc @false

  use Ueberauth.Strategy,
    uid_field: :id,
    default_scope: "",
    oauth2_module: Ueberauth.Strategy.Todoist.OAuth

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  @doc """
  Handles the initial redirect to the todoist authentication page.

  To customize the scope (permissions) that are requested by todoist include them as part of your url:

      "/auth/todoist?scope=data:read"

  You can also include a `state` param that todoist will return to you.
  """
  def handle_request!(conn) do
    scopes = conn.params["scope"] || option(conn, :default_scope)

    opts =
      if conn.params["state"] do
        [scope: scopes, state: conn.params["state"]]
      else
        [scope: scopes]
      end

    module = option(conn, :oauth2_module)
    redirect!(conn, apply(module, :authorize_url!, [opts]))
  end

  @doc """
  Handles the callback from Todoist. When there is a failure from Todoist the failure is included in the
  `ueberauth_failure` struct. Otherwise the information returned from Todoist is returned in the `Ueberauth.Auth` struct.
  """
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    module = option(conn, :oauth2_module)
    token = apply(module, :get_token!, [[code: code]])

    if token.access_token == nil do
      set_errors!(conn, [
        error(token.other_params["error"], nil)
      ])
    else
      fetch_user(conn, token)
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc """
  Cleans up the private area of the connection used for passing the raw Todoist response around during the callback.
  """
  def handle_cleanup!(conn) do
    conn
    |> put_private(:todoist_user, nil)
    |> put_private(:todoist_token, nil)
  end

  @doc """
  Fetches the uid field from the Todoist response. This defaults to the option `uid_field` which in-turn defaults to `id`
  """
  def uid(conn) do
    conn |> option(:uid_field) |> to_string() |> fetch_uid(conn)
  end

  @doc """
  Includes the credentials from the Todoist response.
  """
  def credentials(conn) do
    token = conn.private.todoist_token
    scope_string = token.other_params["scope"] || ""
    scopes = String.split(scope_string, ",")

    %Credentials{
      token: token.access_token,
      refresh_token: token.refresh_token,
      expires_at: token.expires_at,
      token_type: token.token_type,
      expires: !!token.expires_at,
      scopes: scopes
    }
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.todoist_user

    %Info{
      name: user["full_name"],
      email: user["email"],
      location: user["location"],
      image: user["avatar_medium"],
      phone: user["mobile_number"]
    }
  end

  @doc """
  Stores the raw information (including the token) obtained from the Todoist callback.
  """
  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.todoist_token,
        user: conn.private.todoist_user
      }
    }
  end

  defp fetch_uid(field, conn) do
    conn.private.todoist_user[field]
  end

  defp fetch_user(conn, token) do
    conn = put_private(conn, :todoist_token, token)
    resource_types = Ueberauth.json_library().encode!(["user"])

    case Ueberauth.Strategy.Todoist.OAuth.post(
           token,
           "/sync",
           %{sync_token: "*", resource_types: resource_types},
           [{"content-type", "application/x-www-form-urlencoded"}]
         ) do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])

      {:ok, %OAuth2.Response{status_code: status_code, body: %{"user" => user}}}
      when status_code in 200..399 ->
        put_private(conn, :todoist_user, user)

      {:error, %OAuth2.Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end
end
