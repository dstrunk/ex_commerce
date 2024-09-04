defmodule ExCommerceWeb.Resolvers.CartItemResolver do
  alias ExCommerce.{Quote, Repo}
  alias ExCommerce.Sales.QuoteItem
  import Ecto.Query

  def list_items_by_quote(%{id: id}, _args, _info) do
    query =
      from qi in QuoteItem,
        where: qi.quote_id == ^id,
        select: %{
          name: qi.name,
          description: qi.description,
          price: qi.price,
          quantity: qi.quantity
        }

    case Repo.all(query) do
      [] -> {:error, "No items found for Quote ID #{id}."}
      items -> {:ok, items}
    end
  end
end
