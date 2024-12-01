defmodule ExCommerceWeb.Router do
  use ExCommerceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug,
         origin: ["https://excommerce.test", "https://api.excommerce.test"],
         methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
         headers: ["Authorization", "Content-Type", "Accept", "Origin", "User-Agent", "DNT", "Cache-Control", "X-Requested-With", "Referer"],
         max_age: 86400

    plug ExCommerceWeb.Context
    plug Absinthe.Plug,
         schema: ExCommerceWeb.Schema
  end

  scope "/", ExCommerceWeb do
    pipe_through :api
    forward "/", Absinthe.Plug, schema: ExCommerceWeb.Schema
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:ex_commerce, :dev_routes) do
    scope "/dev" do
      forward "/mailbox", Plug.Swoosh.MailboxPreview

      forward "/graphiql", Absinthe.Plug.GraphiQL,
              schema: ExCommerceWeb.Schema,
              interface: :simple,
              context: %{pubsub: ExCommerceWeb.Endpoint}
    end
  end
end
