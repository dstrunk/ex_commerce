defmodule ExCommerce.CustomerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExCommerce.Customer` context.
  """

  @doc """
  Generate a customer.
  """
  def customer_fixture(attrs \\ %{}) do
    {:ok, customer} =
      attrs
      |> Enum.into(%{
        email: "user@example.com",
        first_name: "Example",
        last_name: "User",
        password: "hunter12"
      })
      |> ExCommerce.Customer.create_customer()

    customer
  end

  @doc """
  Generate a address.
  """
  def address_fixture(attrs \\ %{}) do
    customer = customer_fixture()

    {:ok, address} =
      attrs
      |> Enum.into(%{
        address_line_1: "some address_line_1",
        address_line_2: "some address_line_2",
        address_line_3: "some address_line_3",
        administrative_area: "some administrative_area",
        country_code: "some country_code",
        is_default_billing: true,
        is_default_shipping: true,
        locality: "some locality",
        postal_code: "some postal_code",
        customer_id: customer.id
      })
      |> ExCommerce.Customer.create_address()

    address
  end
end
