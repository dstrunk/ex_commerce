defmodule ExCommerceWeb.Resolvers.SessionResolver do
  alias ExCommerce.Quote
  alias ExCommerceWeb.CookieHelper

  def find_user_by_context(_root, _args, %{context: context}) do
    case context[:current_user] do
      nil -> {:error, "Authentication required."}
      user -> {:ok, user}
    end
  end

  def register(_root, args, %{context: context}) do
    with {:ok, user} <- ExCommerce.Account.create_user(args),
         {:ok, token, _claims} <- ExCommerce.Guardian.encode_and_sign(user) do

      if guest_quote = Map.get(context, :current_quote) do
        Quote.transfer_quote_to_user(guest_quote, user)
        CookieHelper.delete_quote_cookie(context.conn)
      end

      {:ok, %{me: user, token: token}}
    else
      {:error, _reason} ->
        {:error, "Unable to sign up"}
    end
  end

  def login(_root, %{email: email, password: password}, %{context: context}) do
    with {:ok, user} <- ExCommerce.Account.authenticate_user(email, password),
         {:ok, token, _claims} <- ExCommerce.Guardian.encode_and_sign(user) do

      if guest_quote = Map.get(context, :current_quote) do
        Quote.transfer_quote_to_user(guest_quote, user)
        CookieHelper.delete_quote_cookie(context.conn)
      end

      {:ok, %{me: user, token: token}}
    else
      {:error, _reason} ->
        {:error, "Invalid email or password"}
    end
  end

  def refresh_token(_root, _args, %{context: %{current_user: user}}) do
    with {:ok, token, _claims} <- ExCommerce.Guardian.encode_and_sign(user, %{}, token_type: "refresh") do
      {:ok, %{me: user, token: token}}
    else
      _ -> {:error, "Unable to refresh token"}
    end
  end
end
