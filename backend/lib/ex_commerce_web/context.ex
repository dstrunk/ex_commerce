defmodule ExCommerceWeb.Context do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    conn
    |> fetch_cookies()
    |> build_context()
    |> put_context(conn)
  end

  defp put_context(context, conn) do
    context = Map.put(context, :conn, conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    user_context = with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
          {:ok, claims} <- ExCommerce.Guardian.decode_and_verify(token),
          {:ok, user} <- ExCommerce.Guardian.resource_from_claims(claims) do
        %{current_user: user}
      else
        _ -> %{}
      end

    quote_context = case conn.cookies["quote_id"]   do
      nil -> %{}
      quote_id ->
        case ExCommerce.Quote.get_quote!(quote_id) do
          nil -> %{}
          quote -> %{current_quote: quote}
        end
    end

    Map.merge(user_context, quote_context)
  end
end
