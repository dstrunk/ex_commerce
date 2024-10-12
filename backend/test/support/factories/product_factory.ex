defmodule ExCommerce.ProductFactory do
  alias ExCommerce.Catalog.Product

  defmacro __using__(_opts) do
    quote do
      def product_factory do
        %Product{
          name: Faker.Commerce.product_name(),
          description: Faker.Lorem.paragraph(3),
          price: Enum.random(10..100),
          quantity: Enum.random(10..1000),
          is_active: Enum.random([true, false])
        }
      end
    end
  end
end
