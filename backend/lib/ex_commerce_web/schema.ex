defmodule ExCommerceWeb.Schema do
  use Absinthe.Schema
  @prototype_schema ExCommerce.Absinthe.OneOfDirective
  alias ExCommerceWeb.Resolvers.{CatalogResolver, CartResolver, CartItemResolver, SessionResolver, CustomerResolver}

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

    field :items, list_of(non_null(:cart_item)) do
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

  object :customer do
    field :id, :id
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :full_name, :string do
      resolve(fn customer, _, _ -> {:ok, "#{customer.first_name} #{customer.last_name}"} end)
    end

    field :addresses, list_of(non_null(:address))
  end

  object :address do
    field :id, :id
    field :address_line_1, :string
    field :address_line_2, :string
    field :address_line_3, :string
    field :locality, :string
    field :postal_code, :string
    field :administrative_area, :string
    field :country_code, :string
    field :is_default_shipping, :boolean
    field :is_default_billing, :boolean
  end

  object :session do
    field :token, :string
    field :me, :customer
  end

  query do
    @desc "Find a specific product by ID"
    field :product, :product do
      arg(:id, non_null(:id))

      resolve(&CatalogResolver.find_product/3)
    end

    @desc "Get a list of all products"
    field :products, list_of(non_null(:product)) do
      resolve(&CatalogResolver.all_products/3)
    end

    @desc "Get a cart by ID"
    field :cart, :cart do
      resolve(&CartResolver.find_quote_by_context/3)
    end

    @desc "Get the current customer"
    field :me, :customer do
      resolve(&SessionResolver.find_customer_by_context/3)
    end
  end

  input_object :cart_item_input do
    field :product_id, non_null(:id)
    field :quantity, non_null(:integer)
  end

  input_object :add_address_input do
    field :address_line_1, non_null(:string)
    field :address_line_2, :string
    field :address_line_3, :string
    field :locality, non_null(:string)
    field :postal_code, non_null(:string)
    field :administrative_area, non_null(:string)
    field :country_code, non_null(:string)
    field :is_default_shipping, :boolean
    field :is_default_billing, :boolean
  end

  input_object :update_address_input do
    field :address_id, non_null(:id)
    field :address_line_1, :string
    field :address_line_2, :string
    field :address_line_3, :string
    field :locality, :string
    field :postal_code, :string
    field :administrative_area, :string
    field :country_code, :string
    field :is_default_shipping, :boolean
    field :is_default_billing, :boolean
  end

  mutation do
    @desc "Add to cart"
    field :cart, :cart do
      arg(:update_items, list_of(non_null(:cart_item_input)))
      #      arg :update_shipping_information, non_null(:update_shipping_information_input)
      #      arg :update_billing_information, non_null(:update_billing_information_input)
      #      arg :finalize, non_null(:finalize_input)

      resolve(&CartResolver.cart/3)
    end

    field :customer, :customer do
      @desc "Add a new address"
      arg(:add_address, :add_address_input)

      @desc "Update a saved address"
      arg(:update_address, :update_address_input)

      resolve(&CustomerResolver.customer/3)
    end

    @desc "Register"
    field :register, :session do
      arg(:email, non_null(:string))
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&SessionResolver.register/3)
    end

    @desc "Login"
    field :login, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&SessionResolver.login/3)
    end

    @desc "Refresh token"
    field :refresh_token, :session do
      resolve(&SessionResolver.refresh_token/3)
    end
  end
end
