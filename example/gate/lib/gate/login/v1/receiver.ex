defmodule Gate.Login.V1.Receiver do

  use Plug.Router

  plug(Guardian.Plug.Pipeline,
    module: Gate.Guardian,
    error_handler: Gate.GuardianErrorHandler
  )

  plug(Guardian.Plug.VerifyHeader, claims: %{typ: "access"})

  plug(Plug.Logger)

  # to be removed in prod
  plug(Corsica, origins: "*", allow_methods: :all, allow_headers: :all)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/ping", do: send_resp(conn, 200, Gate.Login.Handler.ping())

  post "/login" do
    %{"google_token" => id_token} = conn.params
    case Gate.Login.Handler.login(id_token) do

      {:ok, tok, _} ->
        conn
        |> put_resp_header("Cache-Control", "no-store")
        |> put_resp_header("Pragma", "no-cache")
        |> json_resp(%{
          "access_token" => tok,
          "token_type" => "Bearer",
          "expires_in" => 3600
          # "refresh_token": ??
          })

      {:error, code, description} ->
        json_resp(conn, code, %{error: description})

    end
  end

  post "/dummy" do
    case Gate.Schema.validate(:example1, conn.params) do
      true -> json_resp(conn, %{ok: :ok})
      false -> json_resp(conn, 500, %{error: "??"})
    end
  end

  defp json_resp(conn, status \\ 200, obj) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(obj))
    |> halt()
  end


end
