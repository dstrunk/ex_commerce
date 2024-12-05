defmodule ExCommerce.QuoteItem do
  @moduledoc """
  Handles operations related to quote items within a quote.
  """

  import Ecto.Query, warn: false
  alias ExCommerce.Repo

  alias ExCommerce.Repo
  alias ExCommerce.Sales.{Quote, QuoteItem}
  alias ExCommerce.Catalog

  @doc """
  Updates multiple items in a quote simultaneously.

  ## Examples

      iex> update_multiple_items(quote, [%{product_id: 1, quantity: 2}, %{product_id: 2, quantity: 1}])
      {:ok, %Quote{}}

      iex> update_multiple_items(quote, [%{product_id: 1, quantity: -1}])
      {:error, %Ecto.Changeset{}}
  """
  def update_multiple_items(quote, items) do
    Ecto.Multi.new()
    |> process_items(quote, items)
    |> Repo.transaction()
    |> case do
         {:ok, %{quote: updated_quote}} -> {:ok, updated_quote}
         {:error, _failed_operation, failed_value, _changes} -> {:error, failed_value}
       end
  end

  @doc """
  Adds a new item to a quote or updates its quantity if it already exists.
  Removes the item if quantity is set to 0.

  ## Examples

      iex> add_or_update_item(quote, product_id, 2)
      {:ok, %Quote{}}

      iex> add_or_update_item(quote, product_id, 0)
      {:ok, %Quote{}}  # Item removed

  """
  def add_or_update_item(quote, product_id, quantity) do
    existing_item = Enum.find(quote.items, &(&1.product_id == product_id))

    case existing_item do
      nil -> add_item(quote, product_id, quantity)
      item -> update_item(quote, item, quantity)
    end
  end

  defp process_items(multi, quote, items) do
    items
    |> Enum.with_index()
    |> Enum.reduce(multi, fn {%{product_id: product_id, quantity: quantity}, index}, multi ->
      Ecto.Multi.run(multi, {:item, index}, fn _repo, _changes ->
        add_or_update_item(quote, product_id, quantity)
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

  defp add_item(quote, product_id, quantity) do
    product = Catalog.get_product!(product_id)

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

  defp update_item(quote, item, quantity) do
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
