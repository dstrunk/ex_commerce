defmodule ExCommerce.AccountFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExCommerce.Account` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "user@example.com",
        password: "hunter12",
        first_name: "some first_name",
        last_name: "some last_name"
      })
      |> ExCommerce.Account.create_user()

    user
  end
end
