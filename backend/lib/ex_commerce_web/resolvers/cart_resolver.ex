defmodule ExCommerceWeb.Resolvers.CartResolver do
  alias ExCommerce.Quote
  alias ExCommerceWeb.CookieHelper

  def find_quote_by_context(_parent, _args, %{context: context}) do
    case Map.get(context, :current_quote) do
      nil ->
        {:ok, quote} = Quote.find_or_create_quote(Map.get(context, :current_user))
        if conn = Map.get(context, :conn) do
          CookieHelper.put_quote_cookie(context.conn, quote.id)
        end

        {:ok, quote}
      quote ->
        {:ok, quote}
    end
  end

  def cart(_parent, args, %{context: context}) do
    {:ok, quote} = find_quote_by_context(nil, nil, %{context: context})

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

  defp update_items(quote, items) do
    case Quote.update_multiple_items(quote, items) do
      {:ok, updated_quote} -> {:ok, updated_quote}
      {:error, reason} -> {:error, reason}
    end
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
end
