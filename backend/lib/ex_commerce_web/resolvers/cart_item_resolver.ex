defmodule ExCommerceWeb.Resolvers.CartItemResolver do
  alias ExCommerce.{Quote, Repo}
  alias ExCommerce.Sales.QuoteItem
  import Ecto.Query

  def list_items_by_quote(%{id: id}, _args, _info) do
    items = QuoteItem
      |> where([i], i.quote_id == ^id)
      |> Repo.all()

    {:ok, items}
  end
end
