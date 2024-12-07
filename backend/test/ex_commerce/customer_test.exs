defmodule ExCommerce.CustomerTest do
  use ExCommerce.DataCase, async: true
  import ExCommerce.Factory

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

  describe "addresses" do
    alias ExCommerce.Customer.Address

    import ExCommerce.CustomerFixtures

    @invalid_attrs %{address_line_1: nil, address_line_2: nil, address_line_3: nil, locality: nil, postal_code: nil, administrative_area: nil, country_code: nil, is_default_shipping: nil, is_default_billing: nil}

    test "list_addresses/0 returns all addresses" do
      address = address_fixture()
      assert ExCommerce.Customer.list_addresses() == [address]
    end

    test "get_address!/1 returns the address with given id" do
      address = address_fixture()
      assert ExCommerce.Customer.get_address!(address.id) == address
    end

    test "create_address/1 with valid data creates a address" do
      customer = customer_fixture()
      valid_attrs = %{address_line_1: "some address_line_1", address_line_2: "some address_line_2", address_line_3: "some address_line_3", locality: "some locality", postal_code: "some postal_code", administrative_area: "some administrative_area", country_code: "some country_code", is_default_shipping: true, is_default_billing: true, customer_id: customer.id}

      assert {:ok, %Address{} = address} = ExCommerce.Customer.create_address(valid_attrs)
      assert address.address_line_1 == "some address_line_1"
      assert address.address_line_2 == "some address_line_2"
      assert address.address_line_3 == "some address_line_3"
      assert address.locality == "some locality"
      assert address.postal_code == "some postal_code"
      assert address.administrative_area == "some administrative_area"
      assert address.country_code == "some country_code"
      assert address.is_default_shipping == true
      assert address.is_default_billing == true
    end

    test "create_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ExCommerce.Customer.create_address(@invalid_attrs)
    end

    test "update_address/2 with valid data updates the address" do
      address = address_fixture()
      update_attrs = %{address_line_1: "some updated address_line_1", address_line_2: "some updated address_line_2", address_line_3: "some updated address_line_3", locality: "some updated locality", postal_code: "some updated postal_code", administrative_area: "some updated administrative_area", country_code: "some updated country_code", is_default_shipping: false, is_default_billing: false}

      assert {:ok, %Address{} = address} = ExCommerce.Customer.update_address(address, update_attrs)
      assert address.address_line_1 == "some updated address_line_1"
      assert address.address_line_2 == "some updated address_line_2"
      assert address.address_line_3 == "some updated address_line_3"
      assert address.locality == "some updated locality"
      assert address.postal_code == "some updated postal_code"
      assert address.administrative_area == "some updated administrative_area"
      assert address.country_code == "some updated country_code"
      assert address.is_default_shipping == false
      assert address.is_default_billing == false
    end

    test "update_address/2 with invalid data returns error changeset" do
      address = address_fixture()
      assert {:error, %Ecto.Changeset{}} = ExCommerce.Customer.update_address(address, @invalid_attrs)
      assert address == ExCommerce.Customer.get_address!(address.id)
    end

    test "delete_address/1 deletes the address" do
      address = address_fixture()
      assert {:ok, %Address{}} = ExCommerce.Customer.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> ExCommerce.Customer.get_address!(address.id) end
    end

    test "change_address/1 returns a address changeset" do
      address = address_fixture()
      assert %Ecto.Changeset{} = ExCommerce.Customer.change_address(address)
    end
  end
end
