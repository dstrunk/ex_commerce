defmodule ExCommerce.AccountTest do
  use ExCommerce.DataCase

  alias ExCommerce.Account

  describe "users" do
    alias ExCommerce.Account.User

    import ExCommerce.AccountFixtures

    @invalid_attrs %{email: nil, first_name: nil, last_name: nil, password_hash: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Account.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Account.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{email: "user@example.com", first_name: "some first_name", last_name: "some last_name", password: "hunter12"}

      assert {:ok, %User{} = user} = Account.create_user(valid_attrs)
      assert user.email == "user@example.com"
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
      refute Map.has_key?(user, :password)
      refute Map.has_key?(user, :password_hash)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{email: "updated@example.com", first_name: "some updated first_name", last_name: "some updated last_name", password: "hunter34"}

      assert {:ok, %User{} = user} = Account.update_user(user, update_attrs)
      assert user.email == "updated@example.com"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      refute Map.has_key?(user, :password)
      refute Map.has_key?(user, :password_hash)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_user(user, @invalid_attrs)
      assert user == Account.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Account.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Account.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Account.change_user(user)
    end
  end
end
