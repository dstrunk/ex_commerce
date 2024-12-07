defmodule ExCommerce.Customer.Address do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias ExCommerce.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "addresses" do
    field :address_line_1, :string
    field :address_line_2, :string
    field :address_line_3, :string
    field :locality, :string
    field :postal_code, :string
    field :administrative_area, :string
    field :country_code, :string
    field :is_default_shipping, :boolean, default: false
    field :is_default_billing, :boolean, default: false
    belongs_to :customer, ExCommerce.Customer.Customer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, [:address_line_1, :address_line_2, :address_line_3, :locality, :postal_code, :administrative_area, :country_code, :is_default_shipping, :is_default_billing, :customer_id])
    |> validate_required([:address_line_1, :locality, :postal_code, :administrative_area, :country_code, :customer_id])
    |> foreign_key_constraint(:customer_id)
    |> prepare_changes(fn changeset ->
      cond do
        get_change(changeset, :is_default_shipping) ->
          ensure_single_default_shipping(changeset)

        get_change(changeset, :is_default_billing) ->
          ensure_single_default_billing(changeset)

        true ->
          changeset
      end
    end)
  end

  defp ensure_single_default_shipping(changeset) do
    customer_id = get_field(changeset, :customer_id)
    address_id = get_field(changeset, :id)

    query = from a in __MODULE__,
                 where: a.customer_id == ^customer_id,
                 where: a.is_default_shipping == true

    query = if address_id, do: where(query, [a], a.id != ^address_id), else: query

    case Repo.update_all(query, set: [is_default_shipping: false]) do
      {_n, _} -> changeset
      _ -> add_error(changeset, :is_default_shipping, "failed to update other addresses")
    end
  end

  defp ensure_single_default_billing(changeset) do
    customer_id = get_field(changeset, :customer_id)
    address_id = get_field(changeset, :id)

    query = from a in __MODULE__,
                 where: a.customer_id == ^customer_id,
                 where: a.is_default_billing == true

    query = if address_id, do: where(query, [a], a.id != ^address_id), else: query

    case Repo.update_all(query, set: [is_default_billing: false]) do
      {_n, _} -> changeset
      _ -> add_error(changeset, :is_default_billing, "failed to update other addresses")
    end
  end
end
