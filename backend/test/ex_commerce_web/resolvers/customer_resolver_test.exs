defmodule ExCommerceWeb.CustomerResolverTest do
  use ExCommerceWeb.ConnCase, async: true

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
end
