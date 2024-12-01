defmodule ExCommerceWeb.Resolvers.SessionResolver do
  def find_user_by_context(_root, _args, %{context: context}) do
    case context[:current_user] do
      nil -> {:error, "Authentication required."}
      user -> {:ok, user}
    end
  end
end
