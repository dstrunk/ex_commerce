defmodule ExCommerce.AddressFactory do
  alias ExCommerce.Customer.Address

  defmacro __using__(_opts) do
    quote do
      def address_factory do
        %Address{
          address_line_1: "123 Test St",
          locality: "Portland",
          postal_code: "97201",
          administrative_area: "OR",
          country_code: "US",
          customer: build(:customer)
        }
      end
    end
  end
end
