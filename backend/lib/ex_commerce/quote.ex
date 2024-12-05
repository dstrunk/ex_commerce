defmodule ExCommerce.Quote do
  @moduledoc """
  Handles the creation and management of quotes (shopping carts) for both guests and registered users.
  """

  import Ecto.Query, warn: false
  alias ExCommerce.Repo
  alias ExCommerce.Sales.{Quote, QuoteItem}
  alias ExCommerce.Catalog

  @doc """
  Returns a single quote with preloaded items.

  Raises `Ecto.NoResultsError` if the Quote does not exist.

  ## Examples

      iex> get_quote!(123)
      %Quote{items: [%QuoteItem{}, ...]}

      iex> get_quote!(456)
      ** (Ecto.NoResultsError)

  """
  def get_quote!(id), do: Repo.get!(Quote, id) |> Repo.preload(:items)

  @doc """
  Creates a new empty quote for a guest user.

  ## Examples

      iex> create_guest_quote()
      {:ok, %Quote{user_id: nil, items: []}}

  """
  def create_guest_quote do
    create_quote(nil)
  end

  @doc """
  Creates a new quote for a guest user with an initial item.

  ## Examples

      iex> create_guest_quote_with_item(123)
      {:ok, %Quote{user_id: nil, items: [%QuoteItem{product_id: 123, quantity: 1}]}}

      iex> create_guest_quote_with_item(123, 2)
      {:ok, %Quote{user_id: nil, items: [%QuoteItem{product_id: 123, quantity: 2}]}}

      iex> create_guest_quote_with_item(999)
      ** (Ecto.NoResultsError) product not found

  """
  def create_guest_quote_with_item(product_id, quantity \\ 1) do
    create_quote_with_item(nil, product_id, quantity)
  end

  @doc """
  Finds an active quote for a user or creates a new empty one.

  ## Examples

      iex> find_or_create_user_quote(user)
      {:ok, %Quote{user_id: 123, items: []}}

      iex> find_or_create_user_quote(existing_user)
      {:ok, %Quote{user_id: 456, items: [%QuoteItem{}, ...]}}
  """
  def find_or_create_user_quote(user) do
    case get_active_quote(user.id) do
      nil -> create_quote(user.id)
      quote -> {:ok, quote}
    end
  end

  @doc """
  Finds an active quote for a user and adds an item, or creates a new quote with the item.

  ## Examples

      iex> find_or_create_user_quote_with_item(user, 123)
      {:ok, %Quote{user_id: 123, items: [%QuoteItem{product_id: 123, quantity: 1}]}}

      iex> find_or_create_user_quote_with_item(user, 123, 2)
      {:ok, %Quote{user_id: 123, items: [%QuoteItem{product_id: 123, quantity: 2}]}}

      iex> find_or_create_user_quote_with_item(user, 999)
      ** (Ecto.NoResultsError) product not found
  """
  def find_or_create_user_quote_with_item(user, product_id, quantity \\ 1) do
    case get_active_quote(user.id) do
      nil ->
        create_quote_with_item(user.id, product_id, quantity)
      quote ->
        QuoteItem.add_or_update_item(quote, product_id, quantity)
    end
  end

  @doc """
  Transfers a guest quote to a user's account.
  If the user already has an active quote, merges the items.

  ## Examples

      iex> transfer_quote_to_user(guest_quote, user)
      {:ok, %Quote{user_id: 123, items: [%QuoteItem{}, ...]}}

      iex> transfer_quote_to_user(nil, user)
      {:error, :quote_not_found}
  """
  def transfer_quote_to_user(nil, _user), do: {:error, :quote_not_found}
  def transfer_quote_to_user(guest_quote, user) do
    case get_active_quote(user.id) do
      nil ->
        guest_quote
        |> Quote.changeset(%{user_id: user.id})
        |> Repo.update()

      user_quote ->
        # Merge items from guest quote into user quote
        Enum.each(guest_quote.items, fn item ->
          QuoteItem.add_or_update_item(user_quote, item.product_id, item.quantity)
        end)

        # Deactivate guest quote
        guest_quote
        |> Quote.changeset(%{is_active: false})
        |> Repo.update()

        {:ok, user_quote}
    end
  end

  @doc """
  Creates a quote.

  ## Examples

      iex> create_quote(user_id)
      {:ok, %Quote{}}

      iex> create_quote(nil)
      {:ok, %Quote{}}

  """
  def create_quote(user_id) do
    %Quote{}
    |> Quote.changeset(%{user_id: user_id, is_active: true})
    |> Repo.insert()
    |> preload_quote_result()
  end

  defp get_active_quote(user_id) do
    Quote
    |> where(user_id: ^user_id, is_active: true)
    |> preload(:items)
    |> Repo.one()
  end

  defp create_quote_with_item(user_id, product_id, quantity) do
    product = Catalog.get_product!(product_id)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:quote, Quote.changeset(%Quote{}, %{user_id: user_id, is_active: true}))
    |> Ecto.Multi.insert(:quote_item, fn %{quote: quote} ->
      QuoteItem.changeset(%QuoteItem{}, %{
        name: product.name,
        description: product.description,
        price: product.price,
        quantity: quantity,
        quote_id: quote.id,
        product_id: product.id
      })
    end)
    |> Repo.transaction()
    |> handle_quote_creation()
  end

  defp handle_quote_creation({:ok, %{quote: quote, quote_item: _quote_item}}) do
    {:ok, Repo.preload(quote, :items)}
  end

  defp handle_quote_creation({:error, failed_operation, failed_value, _changes_so_far}) do
    {:error, failed_value}
  end

  defp preload_quote_result({:ok, quote}), do: {:ok, Repo.preload(quote, :items, force: true)}
  defp preload_quote_result(error), do: error
end
