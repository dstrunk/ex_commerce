defmodule ExCommerce.Customer do
  @moduledoc """
  The Customer context.
  """

  import Ecto.Query, warn: false
  alias ExCommerce.Repo

  alias ExCommerce.Customer.Customer

  @doc """
  Returns the list of customers.

  ## Examples

      iex> list_customers()
      [%Customer{}, ...]

  """
  def list_customers do
    Customer
    |> Repo.all()
    |> Enum.map(&sanitize_customer/1)
  end

  @doc """
  Gets a single customer.

  Raises `Ecto.NoResultsError` if the Customer does not exist.

  ## Examples

      iex> get_customer!(123)
      %Customer{}

      iex> get_customer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_customer!(id) do
    Customer
    |> where(id: ^id)
    |> Repo.one!()
    |> sanitize_customer()
  end

  @doc """
  Gets a customer by email.

  ## Examples

      iex> get_customer_by_email("customer@example.com")
      {:ok, %Customer{}}

      iex> get_customer_by_email("nonexistent@example.com")
      {:error, :not_found}

  """
  def get_customer_by_email(email) when is_binary(email) do
    case Repo.get_by(Customer, email: email) do
      nil -> {:error, :not_found}
      customer -> {:ok, customer}
    end
  end

  @doc """
  Creates a customer.

  ## Examples

      iex> create_customer(%{field: value})
      {:ok, %Customer{}}

      iex> create_customer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_customer(attrs \\ %{}) do
    %Customer{}
    |> Customer.registration_changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, customer} -> {:ok, sanitize_customer(customer)}
      error -> error
    end
  end

  @doc """
  Updates a customer.

  ## Examples

      iex> update_customer(customer, %{field: new_value})
      {:ok, %Customer{}}

      iex> update_customer(customer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.update_changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, updated_customer} -> {:ok, sanitize_customer(updated_customer)}
      error -> error
    end
  end

  @doc """
  Deletes a customer.

  ## Examples

      iex> delete_customer(customer)
      {:ok, %Customer{}}

      iex> delete_customer(customer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_customer(%Customer{} = customer) do
    Repo.delete(customer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking customer changes.

  ## Examples

      iex> change_customer(customer)
      %Ecto.Changeset{data: %Customer{}}

  """
  def change_customer(%Customer{} = customer, attrs \\ %{}) do
    Customer.update_changeset(customer, attrs)
  end

  def authenticate_customer(email, password) do
    case Repo.get_by(Customer, email: email) do
      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}
      customer ->
        if Argon2.verify_pass(password, customer.password_hash) do
          {:ok, sanitize_customer(customer)}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  defp sanitize_customer(customer) do
    Map.drop(customer, [:password, :new_password, :new_password_confirmation])
  end

  alias ExCommerce.Customer.Address

  @doc """
  Returns the list of addresses.

  ## Examples

      iex> list_addresses()
      [%Address{}, ...]

  """
  def list_addresses do
    Repo.all(Address)
  end

  @doc """
  Gets a single address.

  Raises `Ecto.NoResultsError` if the Address does not exist.

  ## Examples

      iex> get_address!(123)
      %Address{}

      iex> get_address!(456)
      ** (Ecto.NoResultsError)

  """
  def get_address!(id), do: Repo.get!(Address, id)

  @doc """
  Creates a address.

  ## Examples

      iex> create_address(%{field: value})
      {:ok, %Address{}}

      iex> create_address(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_address(attrs \\ %{}) do
    %Address{}
    |> Address.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a address.

  ## Examples

      iex> update_address(address, %{field: new_value})
      {:ok, %Address{}}

      iex> update_address(address, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_address(%Address{} = address, attrs) do
    address
    |> Address.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a address.

  ## Examples

      iex> delete_address(address)
      {:ok, %Address{}}

      iex> delete_address(address)
      {:error, %Ecto.Changeset{}}

  """
  def delete_address(%Address{} = address) do
    Repo.delete(address)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking address changes.

  ## Examples

      iex> change_address(address)
      %Ecto.Changeset{data: %Address{}}

  """
  def change_address(%Address{} = address, attrs \\ %{}) do
    Address.changeset(address, attrs)
  end
end
