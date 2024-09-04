defmodule ExCommerceWeb.CartResolverTest do
  use ExCommerceWeb.ConnCase, async: true
  import ExCommerce.Factory

  @cart_query """
  query GetCart($id: ID!) {
    cart(id: $id) {
      isActive
      items {
        name
        description
        quantity
        price
      }
    }
  }
  """

  test "finds a cart by ID", %{conn: conn} do
    cart = insert(:quote)

    conn =
      post(conn, "/", %{
        "query" => @cart_query,
        "variables" => %{id: cart.id}
      })

    assert json_response(conn, 200) == %{
             "data" => %{
               "cart" => %{
                 "isActive" => cart.is_active,
                 "items" =>
                   Enum.map(cart.items, fn item ->
                     %{
                       "name" => item.name,
                       "description" => item.description,
                       "quantity" => item.quantity,
                       "price" => item.price
                     }
                   end)
               }
             }
           }
  end
end
