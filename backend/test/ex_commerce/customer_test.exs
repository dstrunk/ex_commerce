defmodule ExCommerce.CustomerTest do
  use ExCommerce.DataCase

  describe "customers" do
    alias ExCommerce.Customer.Customer

    import ExCommerce.CustomerFixtures

    @invalid_attrs %{email: nil, first_name: nil, last_name: nil, password_hash: nil}

    test "list_customers/0 returns all customers" do
      customer = customer_fixture()
      assert ExCommerce.Customer.list_customers() == [customer]
    end

    test "get_customer!/1 returns the customer with given id" do
      customer = customer_fixture()
      assert ExCommerce.Customer.get_customer!(customer.id) == customer
    end

    test "create_customer/1 with valid data creates a customer" do
      valid_attrs = %{email: "customer@example.com", first_name: "some first_name", last_name: "some last_name", password: "hunter12"}

      assert {:ok, %Customer{} = customer} = ExCommerce.Customer.create_customer(valid_attrs)
      assert customer.email == "customer@example.com"
      assert customer.first_name == "some first_name"
      assert customer.last_name == "some last_name"

      refute Map.has_key?(customer, :password)
    end

    test "create_customer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ExCommerce.Customer.create_customer(@invalid_attrs)
    end

    test "update_customer/2 with valid data updates the customer" do
      %Customer{id: customer_id} = customer = customer_fixture()
      update_attrs = %{
        email: "updated@example.com",
        first_name: "some updated first_name",
        last_name: "some updated last_name",
        password: "hunter12",
        new_password: "hunter34",
        new_password_confirmation: "hunter34"
      }

      assert {:ok, %Customer{} = updated_customer} = ExCommerce.Customer.update_customer(customer, update_attrs)
      assert updated_customer.id == customer_id
      assert updated_customer.email == "updated@example.com"
      assert updated_customer.first_name == "some updated first_name"
      assert updated_customer.last_name == "some updated last_name"

      # Verify that sensitive fields are not present
      refute Map.has_key?(updated_customer, :password)
      refute Map.has_key?(updated_customer, :new_password)
      refute Map.has_key?(updated_customer, :new_password_confirmation)
    end

    test "update_customer/2 with invalid data returns error changeset" do
      customer = customer_fixture()
      assert {:error, %Ecto.Changeset{}} = ExCommerce.Customer.update_customer(customer, @invalid_attrs)
      assert customer == ExCommerce.Customer.get_customer!(customer.id)
    end

    test "delete_customer/1 deletes the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{}} = ExCommerce.Customer.delete_customer(customer)
      assert_raise Ecto.NoResultsError, fn -> ExCommerce.Customer.get_customer!(customer.id) end
    end

    test "change_customer/1 returns a customer changeset" do
      customer = customer_fixture()
      assert %Ecto.Changeset{} = ExCommerce.Customer.change_customer(customer)
    end
  end
end
