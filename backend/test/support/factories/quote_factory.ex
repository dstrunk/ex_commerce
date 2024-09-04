defmodule ExCommerce.QuoteFactory do
  alias ExCommerce.Sales.Quote

  defmacro __using__(_opts) do
    quote do
      def quote_factory do
        %Quote{
          is_active: Enum.random([true, false]),
          items: build_list(3, :quote_item)
        }
      end
    end
  end
end
