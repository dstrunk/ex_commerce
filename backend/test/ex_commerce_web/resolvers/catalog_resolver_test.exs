defmodule ExCommerceWeb.CatalogResolverTest do
  use ExCommerceWeb.ConnCase, async: true
  import ExCommerce.Factory

  @products_query """
  query GetProducts {
    products {
      name
      description
      price
      quantity
      isActive
    }
  }
  """

  test "gets a list of products", %{conn: conn} do
    products = insert_list(10, :product)
    conn = post(conn, "/", %{
      "query" => @products_query,
    })

    expected_result = Enum.map(products, fn product -> %{
      "description" => product.description,
      "name" => product.name,
      "price" => product.price,
      "quantity" => product.quantity,
      "isActive" => product.is_active,
    } end)

    assert json_response(conn, 200) == %{
      "data" => %{"products" => expected_result}
    }
  end

  @product_query """
  query GetProduct($id: ID!) {
    product(id: $id) {
      name
      description
      price
      quantity
      isActive
    }
  }
  """

  test "finds a product by ID", %{conn: conn} do
    product = insert(:product)
    conn = post(conn, "/", %{
      "query" => @product_query,
      "variables" => %{id: product.id}
    })

    assert json_response(conn, 200) == %{
      "data" => %{"product" => %{
        "description" => product.description,
        "name" => product.name,
        "price" => product.price,
        "quantity" => product.quantity,
        "isActive" => product.is_active,
      }}
    }
  end
end
