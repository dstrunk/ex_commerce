defmodule ExCommerce.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "products" do
    field :name, :string
    field :description, :string
    field :price, :integer
    field :quantity, :integer
    field :is_active, :boolean

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :price, :quantity, :is_active])
    |> validate_required([:name, :description, :price, :quantity, :is_active])
  end
end
