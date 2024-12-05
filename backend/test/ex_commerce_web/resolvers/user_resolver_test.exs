defmodule ExCommerceWeb.UserResolverTest do
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

  test "users are able to log in", %{conn: conn} do
    user_attrs = %{
      email: "user@example.com",
      first_name: "Example",
      last_name: "User",
      password: "password123"
    }

    {:ok, user} = ExCommerce.Account.create_user(user_attrs)

    input = %{
      "email" => user_attrs.email,
      "password" => user_attrs.password
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
                   "id" => user_id,
                   "email" => user_email
                 }
               }
             }
           } = json_response(conn, 200)

    assert token != nil
    assert user_id == to_string(user.id)
    assert user_email == user.email
  end

  test "login fails with incorrect credentials", %{conn: conn} do
    user_attrs = %{
      email: "user@example.com",
      first_name: "Example",
      last_name: "User",
      password: "password123"
    }

    {:ok, _user} = ExCommerce.Account.create_user(user_attrs)

    input = %{
      "email" => user_attrs.email,
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

  test "users are able to register", %{conn: conn} do
    user_attrs = %{
      email: "newuser@example.com",
      firstName: "New",
      lastName: "User",
      password: "password123"
    }

    conn =
      post(conn, "/", %{
        "query" => @register_mutation,
        "variables" => user_attrs
      })

    assert %{
             "data" => %{
               "register" => %{
                 "token" => token,
                 "me" => %{
                   "email" => user_email
                 }
               }
             }
           } = json_response(conn, 200)

    assert token != nil
    assert user_email == user_attrs.email

    # Verify that the user was actually created in the database
    assert {:ok, user} = ExCommerce.Account.get_user_by_email(user_attrs.email)
    assert user.email == user_attrs.email
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
    user_attrs = %{
      email: "existing@example.com",
      first_name: "Another",
      last_name: "Example",
      password: "password123"
    }

    # First, create a user
    {:ok, _user} = ExCommerce.Account.create_user(user_attrs)

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
