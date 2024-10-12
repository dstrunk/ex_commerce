defmodule ExCommerceWeb.UserResolverTest do
  use ExCommerceWeb.ConnCase, async: true

  @login_mutation """
  mutation Login($email: String!, $password: String!) {
    login(email: $email, password: $password) {
      token
      user {
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

      conn = post(conn, "/", %{
        "query" => @login_mutation,
        "variables" => input
      })

      assert %{
        "data" => %{
          "login" => %{
            "token" => token,
            "user" => %{
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

      conn = post(conn, "/", %{
        "query" => @login_mutation,
        "variables" => input
      })

      assert %{
        "data" => %{"login" => nil},
        "errors" => [%{"message" => "Invalid email or password"}]
      } = json_response(conn, 200)
    end

  @register_mutation """
  mutation register($email: String!, $password: String!) {
    register(email: $email, password: $password) {
      token
      user {
        email
      }
    }
  }
  """
end
