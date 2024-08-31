defmodule Ecom.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ecom.Catalog` context.
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
        price: 42
      })
      |> Ecom.Catalog.create_product()

    product
  end
end
