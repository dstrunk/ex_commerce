defmodule ExCommerce.Quote do
  import Ecto.Query, warn: false
  alias ExCommerce.Repo

  alias ExCommerce.Sales.Quote
  alias ExCommerce.Sales.QuoteItem

  # --- Quote actions
  def get_quote!(id), do: Repo.get!(Quote, id) |> Repo.preload(:items)
  def get_quote_by_user(id), do: Repo.get_by(Quote, [user_id: id]) |> Repo.preload(:items)

  def find_or_create_quote(user \\ nil, product_id \\ nil, qty \\ 1) do
    case user do
      nil ->
        if product_id, do: create_quote_with_item(nil, product_id, qty), else: create_empty_quote(nil)

      user ->
        case Repo.get_by(Quote, user_id: user.id, is_active: true) |> Repo.preload(:items) do
          nil ->
            if product_id, do: create_quote_with_item(user.id, product_id, qty), else: create_empty_quote(user.id)

          existing_quote ->
            if product_id, do: add_or_update_item_in_quote(existing_quote, product_id, qty), else: {:ok, existing_quote}
        end
    end
  end

  def create_empty_quote(user_id) do
    %Quote{}
    |> Quote.changeset(%{
      user_id: user_id,
      is_active: true
    })
    |> Repo.insert()
    |> case do
         {:ok, quote} -> {:ok, Repo.preload(quote, :items, force: true)}
         error -> error
       end
  end

  def transfer_quote_to_user(guest_quote, user) do
    case get_quote_by_user(user.id) do
      nil ->
        guest_quote
        |> Quote.changeset(%{user_id: user.id})
        |> Repo.update!()

      user_quote ->
        Enum.each(guest_quote.items, fn item ->
          add_or_update_item_in_quote(user_quote, item.product, item.quantity)
        end)

        guest_quote
        |> Quote.changeset(%{is_active: false})
        |> Repo.update!()

        user_quote
    end
  end

  defp create_quote_with_item(user_id, product_id, qty \\ 1) do
    product = ExCommerce.Catalog.get_product!(product_id)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:quote, %Quote{} |> Quote.changeset(%{
      user_id: user_id,
      is_active: true
    }))
    |> Ecto.Multi.insert(:quote_item, fn %{quote: quote} ->
      %QuoteItem{}
      |> QuoteItem.changeset(%{
        name: product.name,
        description: product.description,
        price: product.price,
        quantity: qty,
        quote_id: quote.id,
        product_id: product.id
      })
    end)
    |> Repo.transaction()
    |> case do
         {:ok, %{quote: quote, quote_item: _quote_item}} ->
           Repo.preload(quote, :items)

         {:error, failed_operation, failed_value, _changes_so_far} ->
           raise "Failed to create quote with item: #{failed_operation}"
       end
  end

  # --- Quote Item actions
  def update_multiple_items(quote, items) do
    Ecto.Multi.new()
    |> process_items(quote, items)
    |> Repo.transaction()
    |> case do
         {:ok, %{quote: updated_quote}} -> {:ok, updated_quote}
         {:error, _failed_operation, failed_value, _changes} -> {:error, failed_value}
       end
  end

  defp process_items(multi, quote, items) do
    items
    |> Enum.with_index()
    |> Enum.reduce(multi, fn {%{product_id: product_id, quantity: quantity}, index}, multi ->
      Ecto.Multi.run(multi, {:item, index}, fn repo, _changes ->
        add_or_update_item_in_quote(quote, product_id, quantity)
      end)
    end)
    |> Ecto.Multi.run(:quote, fn _repo, changes ->
      latest_quote_result = changes
        |> Map.to_list()
        |> Enum.sort_by(fn {{:item, index}, _} -> index end)
        |> List.last()
        |> elem(1)

      {:ok, latest_quote_result}
    end)
  end

  def add_or_update_item_in_quote(quote, product_id, quantity) do
    existing_item = Enum.find(quote.items, fn item ->
      item.product_id == product_id
    end)

    case existing_item do
      nil ->
        add_new_item_to_quote(quote, product_id, quantity)

      item ->
        update_item_in_quote(quote, item, quantity)
    end
  end

  defp add_new_item_to_quote(quote, product_id, quantity) do
    product = ExCommerce.Catalog.get_product!(product_id)

    %QuoteItem{}
    |> QuoteItem.changeset(%{
      name: product.name,
      description: product.description,
      price: product.price,
      quantity: quantity,
      quote_id: quote.id,
      product_id: product.id
    })
    |> Repo.insert()
    |> case do
         {:ok, _quote_item} -> {:ok, Repo.preload(quote, :items, force: true)}
         {:error, changeset} -> {:error, changeset}
       end
  end

  defp update_item_in_quote(quote, item, quantity) do
    if quantity == 0 do
      Repo.delete(item)
      |> case do
           {:ok, _deleted_item} -> {:ok, Repo.preload(quote, :items, force: true)}
           error -> error
         end
    else
      item
      |> QuoteItem.changeset(%{quantity: quantity})
      |> Repo.update()
      |> case do
           {:ok, _updated_item} -> {:ok, Repo.preload(quote, :items, force: true)}
           error -> error
      end
    end
  end
end
