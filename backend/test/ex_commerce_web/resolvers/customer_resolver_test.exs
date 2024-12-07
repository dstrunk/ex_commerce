defmodule ExCommerceWeb.CustomerResolverTest do
  use ExCommerceWeb.ConnCase, async: true
  import ExCommerce.Factory

  alias ExCommerceWeb.Resolvers.CustomerResolver
  alias ExCommerce.Repo

  @login_mutation """
  mutation Login($email: String!, $password: String!) {
    login(email: $email, password: $password) {
      token
      me {
        id
        email
      }
    }
  }
  """

  test "customers are able to log in", %{conn: conn} do
    customer_attrs = %{
      email: "customer@example.com",
      first_name: "Example",
      last_name: "Customer",
      password: "password123"
    }

    {:ok, customer} = ExCommerce.Customer.create_customer(customer_attrs)

    input = %{
      "email" => customer_attrs.email,
      "password" => customer_attrs.password
    }

    conn =
      post(conn, "/", %{
        "query" => @login_mutation,
        "variables" => input
      })

    assert %{
             "data" => %{
               "login" => %{
                 "token" => token,
                 "me" => %{
                   "id" => customer_id,
                   "email" => customer_email
                 }
               }
             }
           } = json_response(conn, 200)

    assert token != nil
    assert customer_id == to_string(customer.id)
    assert customer_email == customer.email
  end

  test "login fails with incorrect credentials", %{conn: conn} do
    customer_attrs = %{
      email: "customer@example.com",
      first_name: "Example",
      last_name: "Customer",
      password: "password123"
    }

    {:ok, _customer} = ExCommerce.Customer.create_customer(customer_attrs)

    input = %{
      "email" => customer_attrs.email,
      "password" => "wrongpassword"
    }

    conn =
      post(conn, "/", %{
        "query" => @login_mutation,
        "variables" => input
      })

    assert %{
             "data" => %{"login" => nil},
             "errors" => [%{"message" => "Invalid email or password"}]
           } = json_response(conn, 200)
  end

  @register_mutation """
  mutation register($email: String!, $firstName: String!, $lastName: String!, $password: String!) {
    register(email: $email, firstName: $firstName, lastName: $lastName, password: $password) {
      token
      me {
        email
        firstName
        lastName
      }
    }
  }
  """

  test "customers are able to register", %{conn: conn} do
    customer_attrs = %{
      email: "newcustomer@example.com",
      firstName: "New",
      lastName: "Customer",
      password: "password123"
    }

    conn =
      post(conn, "/", %{
        "query" => @register_mutation,
        "variables" => customer_attrs
      })

    assert %{
             "data" => %{
               "register" => %{
                 "token" => token,
                 "me" => %{
                   "email" => customer_email
                 }
               }
             }
           } = json_response(conn, 200)

    assert token != nil
    assert customer_email == customer_attrs.email

    # Verify that the customer was actually created in the database
    assert {:ok, customer} = ExCommerce.Customer.get_customer_by_email(customer_attrs.email)
    assert customer.email == customer_attrs.email
  end

  test "registration fails with invalid data", %{conn: conn} do
    invalid_attrs = %{
      email: "invalid-email",
      firstName: "",
      lastName: "",
      password: "short"
    }

    conn =
      post(conn, "/", %{
        "query" => @register_mutation,
        "variables" => invalid_attrs
      })

    assert %{
             "data" => %{"register" => nil},
             "errors" => [%{"message" => error_message}]
           } = json_response(conn, 200)

    assert error_message =~ "Unable to sign up"
  end

  test "registration fails with duplicate email", %{conn: conn} do
    customer_attrs = %{
      email: "existing@example.com",
      first_name: "Another",
      last_name: "Example",
      password: "password123"
    }

    # First, create a customer
    {:ok, _customer} = ExCommerce.Customer.create_customer(customer_attrs)

    # Try to register with the same email
    conn =
      post(conn, "/", %{
        "query" => @register_mutation,
        "variables" => %{
          email: "existing@example.com",
          firstName: "Another",
          lastName: "Example",
          password: "password456"
        }
      })

    assert %{
             "data" => %{"register" => nil},
             "errors" => [%{"message" => error_message}]
           } = json_response(conn, 200)

    assert error_message =~ "Unable to sign up"
  end

  describe "customer addresses" do
    test "customers can add a default shipping address" do
      customer = insert(:customer)
      address_attrs = %{
        address_line_1: "123 Main St",
        locality: "Portland",
        postal_code: "97201",
        administrative_area: "OR",
        country_code: "US",
        is_default_shipping: true
      }

      context = %{context: %{current_customer: customer}}

      assert {:ok, address} =
               CustomerResolver.customer(nil, %{add_address: address_attrs}, context)

      assert address.address_line_1 == "123 Main St"
      assert address.is_default_shipping == true
      assert address.customer_id == customer.id
    end

    test "customers can add a default billing address" do
      customer = insert(:customer)
      address_attrs = %{
        address_line_1: "456 Oak Ave",
        locality: "Portland",
        postal_code: "97201",
        administrative_area: "OR",
        country_code: "US",
        is_default_billing: true
      }

      context = %{context: %{current_customer: customer}}

      assert {:ok, address} =
               CustomerResolver.customer(nil, %{add_address: address_attrs}, context)

      assert address.is_default_billing == true
      assert address.customer_id == customer.id
    end

    test "customers adding a new default shipping address will unset the previous default shipping address" do
      customer = insert(:customer)
      old_address = insert(:address, customer: customer, is_default_shipping: true)

      new_address_attrs = %{
        address_line_1: "789 Pine St",
        locality: "Portland",
        postal_code: "97201",
        administrative_area: "OR",
        country_code: "US",
        is_default_shipping: true
      }

      context = %{context: %{current_customer: customer}}

      assert {:ok, new_address} =
               CustomerResolver.customer(nil, %{add_address: new_address_attrs}, context)

      # Reload the old address to check its updated status
      updated_old_address = Repo.reload!(old_address)

      assert new_address.is_default_shipping == true
      refute updated_old_address.is_default_shipping
    end

    test "customers adding a new default billing address will unset the previous default billing address" do
      customer = insert(:customer)
      old_address = insert(:address, customer: customer, is_default_billing: true)

      new_address_attrs = %{
        address_line_1: "321 Elm St",
        locality: "Portland",
        postal_code: "97201",
        administrative_area: "OR",
        country_code: "US",
        is_default_billing: true
      }

      context = %{context: %{current_customer: customer}}

      assert {:ok, new_address} =
               CustomerResolver.customer(nil, %{add_address: new_address_attrs}, context)

      updated_old_address = Repo.reload!(old_address)

      assert new_address.is_default_billing == true
      refute updated_old_address.is_default_billing
    end

    test "returns error when customer is not authenticated" do
      address_attrs = %{
        address_line_1: "123 Main St",
        locality: "Portland",
        postal_code: "97201",
        administrative_area: "OR",
        country_code: "US"
      }

      context = %{context: %{}}

      assert {:error, "Customer is not logged in"} =
               CustomerResolver.customer(nil, %{add_address: address_attrs}, context)
    end

    test "cannot update address belonging to different customer" do
      customer = insert(:customer)
      other_customer = insert(:customer)
      address = insert(:address, customer: other_customer)

      update_attrs = %{
        address_id: address.id,
        address_line_1: "New Address"
      }

      context = %{context: %{current_customer: customer}}

      assert {:error, "Address not found"} =
               CustomerResolver.customer(nil, %{update_address: update_attrs}, context)
    end
  end
end
