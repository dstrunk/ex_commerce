defmodule ExCommerce.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :address_line_1, :string
      add :address_line_2, :string, null: true
      add :address_line_3, :string, null: true
      add :locality, :string
      add :postal_code, :string
      add :administrative_area, :string
      add :country_code, :string
      add :is_default_shipping, :boolean, default: false, null: false
      add :is_default_billing, :boolean, default: false, null: false
      add :customer_id, references(:customers, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:addresses, [:customer_id])

    # Partial unique index to only allow one default shipping address
    create unique_index(:addresses, [:customer_id],
      where: "is_default_shipping = true",
      name: "addresses_default_shipping_index"
    )

    # Partial unique index to only allow one default billing address
    create unique_index(:addresses, [:customer_id],
      where: "is_default_billing = true",
      name: "addresses_default_billing_index"
    )
  end
end
