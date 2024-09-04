defmodule ExCommerceWeb.Resolvers.CatalogResolver do
  alias ExCommerce.Catalog

  def all_products(_root, _args, _info) do
    {:ok, Catalog.list_products()}
  end

  def find_product(_root, %{id: id}, _info) do
    {:ok, Catalog.get_product!(id)}
  end
end
