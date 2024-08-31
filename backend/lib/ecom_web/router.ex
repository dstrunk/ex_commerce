defmodule EcomWeb.Router do
  use EcomWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", EcomWeb do
    pipe_through :api
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:ecom, :dev_routes) do
    scope "/dev" do
      forward "/mailbox", Plug.Swoosh.MailboxPreview

      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: EcomWeb.Schema,
        interface: :simple,
        context: %{pubsub: EcomWeb.Endpoint}
    end
  end
end
