defmodule ExCommerce.Repo.Migrations.CreateQuotes do
  use Ecto.Migration

  def change do
    create table(:quotes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_active, :boolean, null: false, default: true

      timestamps(type: :utc_datetime)
    end

    create index("quotes", [:is_active])
  end
end
