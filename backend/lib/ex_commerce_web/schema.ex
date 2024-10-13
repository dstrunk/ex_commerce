defmodule ExCommerceWeb.Schema do
  use Absinthe.Schema
  alias ExCommerceWeb.Resolvers.{CatalogResolver, CartResolver, CartItemResolver}

  import_types(Absinthe.Type.Custom)

  object :product do
    field :name, non_null(:string)
    field :description, :string
    field :price, non_null(:integer)
    field :quantity, :integer
    field :is_active, :boolean
  end

  object :cart do
    field :is_active, :boolean

    field :items, list_of(:cart_item) do
      resolve(&CartItemResolver.list_items_by_quote/3)
    end
  end

  object :cart_item do
    field :name, non_null(:string)
    field :description, :string
    field :price, non_null(:integer)
    field :quantity, :integer
    field :is_active, :boolean
  end

  object :user do
    field :id, :id
    field :email, :string
    field :first_name, :string
    field :last_name, :string
  end

  object :session do
    field :token, :string
    field :user, :user
  end

  query do
    @desc "Find a specific product by ID"
    field :product, :product do
      arg(:id, non_null(:id))

      resolve(&CatalogResolver.find_product/3)
    end

    @desc "Get a list of all products"
    field :products, non_null(list_of(non_null(:product))) do
      resolve(&CatalogResolver.all_products/3)
    end

    @desc "Get a cart by ID"
    field :cart, :cart do
      arg(:id, non_null(:id))

      resolve(&CartResolver.find_quote/3)
    end
  end

  mutation do
    @desc "Register"
    field :register, :session do
      arg :email, non_null(:string)
      arg :first_name, non_null(:string)
      arg :last_name, non_null(:string)
      arg :password, non_null(:string)

      resolve fn _, args, _ ->
        with {:ok, user} <- ExCommerce.Account.create_user(args),
             {:ok, token, _claims} <- ExCommerce.Guardian.encode_and_sign(user) do
          {:ok, %{user: user, token: token}}
        else
          {:error, _reason} ->
            {:error, "Unable to sign up"}
        end
      end
    end

    @desc "Login"
    field :login, :session do
      arg :email, non_null(:string)
      arg :password, non_null(:string)

      resolve fn _, %{email: email, password: password}, _ ->
        with {:ok, user} <- ExCommerce.Account.authenticate_user(email, password),
             {:ok, token, _claims} <- ExCommerce.Guardian.encode_and_sign(user) do
          {:ok, %{user: user, token: token}}
        else
          {:error, _reason} ->
            {:error, "Invalid email or password"}
        end
      end
    end
  end
end
