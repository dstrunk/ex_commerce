defmodule ExCommerce.Repo.Migrations.CreateQuoteItems do
  use Ecto.Migration

  def change do
    create table(:quote_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :string
      add :price, :integer, null: false
      add :quantity, :integer, null: false
      add :quote_id, references(:quotes, type: :uuid, on_delete: :delete_all)
      add :product_id, references(:products, type: :uuid, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index("quote_items", [:name])
  end
end
