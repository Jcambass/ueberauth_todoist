# Überauth Todoist

> Todoist OAuth2 strategy for Überauth.

## Installation

1. Setup your application at [Todoist App Management](https://developer.todoist.com/appconsole.html).

1. Add `:ueberauth_todoist` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_todoist, "~> 1.0"}]
    end
    ```

1. Add Todoist to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        todoist: {Ueberauth.Strategy.Todoist, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Todoist.OAuth,
      client_id: System.get_env("TODOIST_CLIENT_ID"),
      client_secret: System.get_env("TODOIST_CLIENT_SECRET")
    ```

    Or, to read the client credentials at runtime:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Todoist.OAuth,
      client_id: {:system, "TODOIST_CLIENT_ID"},
      client_secret: {:system, "TODOIST_CLIENT_SECRET"}
    ```

1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller

      pipeline :browser do
        plug Ueberauth
        ...
       end
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initiate the request through:

    /auth/todoist

Or with options:

    /auth/toddoist?scope=data:read

Scope can be configured either explicitly as a `scope` query value on the request path or in your configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Todoist, [default_scope: "data:read"]}
  ]
```

## License

Please see [LICENSE](https://github.com/jcambass/ueberauth_todoist/blob/master/LICENSE) for licensing details.
