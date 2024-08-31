defmodule EcomWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :ecom
  use Absinthe.Phoenix.Endpoint

  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :ecom
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Absinthe.Plug,
    schema: EcomWeb.Schema
end
