defmodule ExCommerce.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :string
      add :price, :integer, null: false
      add :quantity, :integer, null: false
      add :is_active, :boolean, null: false, default: true

      timestamps(type: :utc_datetime)
    end

    create index("products", [:name])
    create constraint("products", "price_must_be_positive", check: "price > 0")
  end
end
