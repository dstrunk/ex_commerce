defmodule ExCommerceWeb.Resolvers.CartResolver do
  alias ExCommerce.Quote

  def find_quote(_root, %{id: id}, _info) do
    {:ok, Quote.get_quote!(id)}
  end
end
