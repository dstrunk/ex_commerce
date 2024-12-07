defmodule ExCommerceWeb.Resolvers.SessionResolver do
  alias ExCommerce.Quote
  alias ExCommerceWeb.CookieHelper

  def find_customer_by_context(_root, _args, %{context: context}) do
    case context[:current_customer] do
      nil -> {:error, "Authentication required."}
      customer -> {:ok, customer}
    end
  end

  def register(_root, args, %{context: context}) do
    with {:ok, customer} <- ExCommerce.Customer.create_customer(args),
         {:ok, token, _claims} <- ExCommerce.Guardian.encode_and_sign(customer) do

      if guest_quote = Map.get(context, :current_quote) do
        Quote.transfer_quote_to_customer(guest_quote, customer)
        CookieHelper.delete_quote_cookie(context.conn)
      end

      {:ok, %{me: customer, token: token}}
    else
      {:error, _reason} ->
        {:error, "Unable to sign up"}
    end
  end

  def login(_root, %{email: email, password: password}, %{context: context}) do
    with {:ok, customer} <- ExCommerce.Customer.authenticate_customer(email, password),
         {:ok, token, _claims} <- ExCommerce.Guardian.encode_and_sign(customer) do

      if guest_quote = Map.get(context, :current_quote) do
        Quote.transfer_quote_to_customer(guest_quote, customer)
        CookieHelper.delete_quote_cookie(context.conn)
      end

      {:ok, %{me: customer, token: token}}
    else
      {:error, _reason} ->
        {:error, "Invalid email or password"}
    end
  end

  def refresh_token(_root, _args, %{context: %{current_customer: customer}}) do
    with {:ok, token, _claims} <- ExCommerce.Guardian.encode_and_sign(customer, %{}, token_type: "refresh") do
      {:ok, %{me: customer, token: token}}
    else
      _ -> {:error, "Unable to refresh token"}
    end
  end
end
