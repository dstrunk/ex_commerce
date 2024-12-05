defmodule ExCommerceWeb.Resolvers.CartResolver do
  alias ExCommerce.{Quote, QuoteItem}
  alias ExCommerceWeb.CookieHelper

  def find_quote_by_context(_parent, _args, %{context: context}) do
    case Map.get(context, :current_quote) do
      nil ->
        create_quote_from_context(context)
      quote ->
        {:ok, quote}
    end
  end

  def cart(_parent, args, %{context: context}) do
    with {:ok, quote} <- find_quote_by_context(nil, nil, %{context: context}) do
      case args do
        %{update_items: items} when is_list(items) ->
          update_items(quote, items)

        %{update_shipping_information: params} ->
          update_shipping_information(quote)

        %{update_billing_information: params} ->
          update_billing_information(quote)

        %{finalize: params} ->
          finalize(quote)

        _ ->
          {:error, "Invalid cart operation"}
      end
    end
  end

  defp update_items(quote, items) do
    QuoteItem.update_multiple_items(quote, items)
  end

  defp update_shipping_information(quote) do
    {:ok, quote}
  end

  defp update_billing_information(quote) do
    {:ok, quote}
  end

  defp finalize(quote) do
    {:ok, quote}
  end

  defp create_quote_from_context(context) do
    result = case Map.get(context, :current_user) do
      nil ->
        Quote.create_guest_quote()
      user ->
        Quote.find_or_create_user_quote(user)
    end

    case result do
      {:ok, quote} ->
        if conn = Map.get(context, :conn) do
          CookieHelper.put_quote_cookie(conn, quote.id)
        end
        {:ok, quote}
      error ->
        error
    end
  end
end
