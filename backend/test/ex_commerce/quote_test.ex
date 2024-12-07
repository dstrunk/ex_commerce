defmodule ExCommerce.QuoteTest do
  use ExCommerce.DataCase
  import ExCommerce.Factory

  alias ExCommerce.Quote

  describe "create_empty_quote/1" do
    test "creates a quote with no items" do
      {:ok, quote} = Quote.create_empty_quote(nil)

      assert quote.is_active == true
      assert quote.customer_id == nil
      assert quote.items == []
    end

    test "creates a quote with customer_id" do
      customer = build(:customer)
      {:ok, quote} = Quote.create_empty_quote(customer.id)

      assert quote.is_active == true
      assert quote.customer_id == customer.id
      assert quote.items == []
    end
  end

  describe "add_or_update_item_in_quote/3" do
    test "adds new item when it doesn't exist" do
      quote = insert(:quote, items: [])
      product = insert(:product)

      {:ok, updated_quote} = Quote.add_or_update_item_in_quote(quote, product.id, 1)

      assert length(updated_quote.items) == 1
      item = List.first(updated_quote.items)
      assert item.product_id == product.id
      assert item.quantity == 1
      assert item.name == product.name
      assert item.price == product.price
    end

    test "updates quantity when item exists" do
      product = insert(:product)
      quote_item = insert(:quote_item, product_id: product.id, quantity: 1)
      quote = insert(:quote, items: [quote_item])

      {:ok, updated_quote} = Quote.add_or_update_item_in_quote(quote, product.id, 2)

      assert length(updated_quote.items) == 1
      item = List.first(updated_quote.items)
      assert item.quantity == 2
    end

    test "removes item when quantity is 0" do
      product = insert(:product)
      quote_item = insert(:quote_item, product_id: product.id, quantity: 1)
      quote = insert(:quote, items: [quote_item])

      {:ok, updated_quote} = Quote.add_or_update_item_in_quote(quote, product.id, 0)

      assert updated_quote.items == []
    end
  end

  describe "update_multiple_items/2" do
    test "successfully adds new items to an empty quote" do
      quote = insert(:quote, items: [])
      products = insert_list(2, :product)

      items = Enum.map(products, fn product -> %{
        product_id: product.id,
        quantity: 1
      } end)

      {:ok, updated_quote} = Quote.update_multiple_items(quote, items)

      assert length(updated_quote.items) == 2
      assert Enum.all?(updated_quote.items, fn item ->
        Enum.any?(products, fn product ->
          item.product_id == product.id &&
          item.name == product.name &&
          item.description == product.description &&
          item.price == product.price &&
          item.quantity == 1
        end)
      end)
    end

    test "updates existing items and adds new ones" do
      product1 = insert(:product)
      quote_item = insert(:quote_item, product_id: product1.id, quantity: 1)
      quote = insert(:quote, items: [quote_item])
      product2 = insert(:product)

      items = [
        %{product_id: product1.id, quantity: 2},
        %{product_id: product2.id, quantity: 1}
      ]

      {:ok, updated_quote} = Quote.update_multiple_items(quote, items)

      assert length(updated_quote.items) == 2
      assert Enum.any?(updated_quote.items, fn item ->
        item.product_id == product1.id && item.quantity == 2
      end)
      assert Enum.any?(updated_quote.items, fn item ->
        item.product_id == product2.id && item.quantity == 1
      end)
    end
  end
end
