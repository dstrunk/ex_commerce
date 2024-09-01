defmodule Ecom.ProductFactory do
  alias Ecom.Catalog.Product

  defmacro __using__(_opts) do
    quote do
      def product_factory do
        %Product{
          name: Faker.Commerce.product_name(),
          description: Faker.Lorem.paragraph(3),
          price: Enum.random(10..100),
        }
      end
    end
  end
end
