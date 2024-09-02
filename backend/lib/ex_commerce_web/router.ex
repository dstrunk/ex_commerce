defmodule ExCommerceWeb.Router do
  use ExCommerceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ExCommerceWeb do
    pipe_through :api
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
