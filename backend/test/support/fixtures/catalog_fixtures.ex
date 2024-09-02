defmodule ExCommerce.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExCommerce.Catalog` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        price: 42,
        quantity: 100,
        is_active: true
      })
      |> ExCommerce.Catalog.create_product()

    product
  end
end
