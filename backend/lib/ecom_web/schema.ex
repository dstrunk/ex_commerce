defmodule EcomWeb.Schema do
  use Absinthe.Schema

  import_types Absinthe.Type.Custom

  object :product do
    field :name, non_null(:string)
    field :description, :string
    field :price, non_null(:integer)
  end

  query do
    field :product, :product do
      arg :id, non_null(:id)
      resolve fn %{id: product_id}, _ ->
        {:ok, Ecom.Catalog.get_product!(product_id)}
      end
    end
  end
end
