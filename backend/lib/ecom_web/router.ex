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
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
