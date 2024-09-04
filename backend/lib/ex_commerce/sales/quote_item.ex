defmodule ExCommerce.Sales.QuoteItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "quote_items" do
    field :name, :string
    field :description, :string
    field :price, :integer
    field :quantity, :integer
    belongs_to :quote, ExCommerce.Sales.Quote
    belongs_to :product, ExCommerce.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(quote_item, attrs) do
    quote_item
    |> cast(attrs, [:name, :description, :price, :quantity])
    |> validate_required([:name, :description, :price, :quantity])
    |> assoc_constraint(:quote)
    |> assoc_constraint(:product)
  end
end
