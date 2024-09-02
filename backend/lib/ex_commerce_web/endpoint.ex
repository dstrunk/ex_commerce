defmodule ExCommerceWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :ex_commerce
  use Absinthe.Phoenix.Endpoint

  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :ex_commerce
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  if Application.compile_env(:ex_commerce, :dev_routes) do
    plug Plug.MethodOverride
    plug Plug.Head
    plug ExCommerceWeb.Router
  end

  plug Absinthe.Plug,
    schema: ExCommerceWeb.Schema
end
