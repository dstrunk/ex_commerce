defmodule ExCommerce.QuoteItemFactory do
  alias ExCommerce.Sales.QuoteItem

  defmacro __using__(_opts) do
    quote do
      def quote_item_factory do
        %QuoteItem{
          name: Faker.Commerce.product_name(),
          description: Faker.Lorem.paragraph(3),
          price: Enum.random(10..100),
          quantity: Enum.random(10..1000)
        }
      end
    end
  end
end
