defmodule ExCommerceWeb.Schema do
  use Absinthe.Schema
  alias ExCommerceWeb.CatalogResolver

  import_types Absinthe.Type.Custom

  object :product do
    field :name, non_null(:string)
    field :description, :string
    field :price, non_null(:integer)
    field :quantity, :integer
    field :is_active, :boolean
  end

  query do
    @desc "Find a specific product by ID"
    field :product, :product do
      arg :id, non_null(:id)

      resolve &CatalogResolver.find_product/3
    end

    @desc "Get a list of all products"
    field :products, non_null(list_of(non_null(:product))) do
      resolve &CatalogResolver.all_products/3
    end
  end
end
