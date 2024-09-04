defmodule ExCommerce.Sales.Quote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "quotes" do
    field :is_active, :boolean, default: true
    has_many :items, ExCommerce.Sales.QuoteItem

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(quote, attrs) do
    quote
    |> cast(attrs, [:is_active])
    |> validate_required([:is_active])
    |> assoc_constraint(:items)
  end
end
