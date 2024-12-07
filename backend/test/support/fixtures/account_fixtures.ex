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
        email: "customer@example.com",
        password: "hunter12",
        first_name: "some first_name",
        last_name: "some last_name"
      })
      |> ExCommerce.Customer.create_customer()

    customer
  end
end
