defmodule ExCommerceWeb.CartResolverTest do
  use ExCommerceWeb.ConnCase, async: true
  import ExCommerce.Factory

  setup %{conn: conn} do
    conn = conn
           |> recycle()
           |> Plug.Test.init_test_session(%{})
           |> fetch_cookies()
           |> delete_resp_cookie("quote_id")

    {:ok, %{conn: conn}}
  end

  @cart_query """
  query GetCart {
    cart {
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

  test "empty carts return an empty array", %{conn: conn} do
    cart = insert(:quote, items: [])
    conn = post(conn, "/", %{
      "query" => @cart_query,
      "variables" => %{id: cart.id}
    })

    assert json_response(conn, 200) == %{
             "data" => %{
               "cart" => %{
                 "isActive" => cart.is_active,
                 "items" => []
               }
             }
           }
  end

  test "returns existing cart items", %{conn: conn} do
    product = insert(:product)
    quote_item = insert(:quote_item, product_id: product.id, quantity: 2)
    quote = insert(:quote, items: [quote_item])
    conn = put_resp_cookie(conn, "quote_id", quote.id)
    conn = post(conn, "/", %{
      "query" => @cart_query
    })
    assert json_response(conn, 200) == %{
             "data" => %{
               "cart" => %{
                 "isActive" => true,
                 "items" => [
                   %{
                     "name" => quote_item.name,
                     "description" => quote_item.description,
                     "quantity" => quote_item.quantity,
                     "price" => quote_item.price,
                   }
                 ]
               }
             }
           }
  end

  @update_cart_mutation """
  mutation UpdateCart($items: [CartItemInput!]) {
    cart(updateItems: $items) {
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

  describe "update cart items" do
    test "can add new items to cart", %{conn: conn} do
      quote = insert(:quote, items: [])
      products = insert_list(2, :product)

      conn = put_resp_cookie(conn, "quote_id", quote.id)
      variables = %{
        "items" => Enum.map(products, fn product -> %{
                                                      "productId" => product.id,
                                                      "quantity" => 1,
                                                    } end)
      }

      conn = post(conn, "/", %{
        "query" => @update_cart_mutation,
        "variables" => variables,
      })

      assert json_response(conn, 200) == %{
               "data" => %{"cart" => %{
                 "isActive" => true,
                 "items" => Enum.map(products, fn product -> %{
                                                               "name" => product.name,
                                                               "description" => product.description,
                                                               "quantity" => 1,
                                                               "price" => product.price,
                                                             } end)
               }}
             }
    end

    test "can update quantity of existing items", %{conn: conn} do
      product = insert(:product)
      quote_item = build(:quote_item) |> from_product(product) |> insert()
      quote = insert(:quote, items: [quote_item])

      conn = put_resp_cookie(conn, "quote_id", quote.id)
      variables = %{
        "items" => [%{
          "productId" => product.id,
          "quantity" => 3
        }]
      }

      conn = post(conn, "/", %{
        "query" => @update_cart_mutation,
        "variables" => variables
      })

      assert json_response(conn, 200) == %{
               "data" => %{
                 "cart" => %{
                   "isActive" => true,
                   "items" => [%{
                     "name" => product.name,
                     "description" => product.description,
                     "quantity" => 3,
                     "price" => product.price
                   }]
                 }
               }
             }
    end

    test "can remove items by setting quantity to 0", %{conn: conn} do
      product = insert(:product)
      quote_item = build(:quote_item, quantity: 1) |> from_product(product) |> insert()
      quote = insert(:quote, items: [quote_item])

      conn = put_resp_cookie(conn, "quote_id", quote.id)
      variables = %{
        "items" => [%{
          "productId" => product.id,
          "quantity" => 0
        }]
      }

      conn = post(conn, "/", %{
        "query" => @update_cart_mutation,
        "variables" => variables
      })

      assert json_response(conn, 200) == %{
               "data" => %{
                 "cart" => %{
                   "isActive" => true,
                   "items" => []
                 }
               }
             }
    end

    test "can simultaneously update some items and remove others", %{conn: conn} do
      product1 = insert(:product)
      product2 = insert(:product)
      quote_item1 = build(:quote_item, quantity: 1) |> from_product(product1) |> insert()
      quote_item2 = build(:quote_item, quantity: 1) |> from_product(product2) |> insert()
      quote = insert(:quote, items: [quote_item1, quote_item2])

      conn = put_resp_cookie(conn, "quote_id", quote.id)
      variables = %{
        "items" => [
          %{"productId" => product1.id, "quantity" => 2},
          %{"productId" => product2.id, "quantity" => 0}
        ]
      }

      conn = post(conn, "/", %{
        "query" => @update_cart_mutation,
        "variables" => variables
      })

      assert json_response(conn, 200) == %{
               "data" => %{
                 "cart" => %{
                   "isActive" => true,
                   "items" => [%{
                     "name" => product1.name,
                     "description" => product1.description,
                     "quantity" => 2,
                     "price" => product1.price
                   }]
                 }
               }
             }
    end
  end
end
