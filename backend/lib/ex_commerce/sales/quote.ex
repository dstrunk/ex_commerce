defmodule ExCommerce.Sales.Quote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "quotes" do
    field :is_active, :boolean, default: true
    belongs_to :user, ExCommerce.Account.User
    has_many :items, ExCommerce.Sales.QuoteItem

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(quote, attrs) do
    quote
    |> cast(attrs, [:is_active, :user_id])
    |> validate_required([:is_active])
    |> maybe_check_items_constraint(quote)
    |> foreign_key_constraint(:user_id)
  end

  defp maybe_check_items_constraint(changeset, quote) do
    case get_field(changeset, :items) do
      items when is_list(items) and length(items) > 0 -> assoc_constraint(changeset, :items)
      _ -> changeset
    end
  end
end
