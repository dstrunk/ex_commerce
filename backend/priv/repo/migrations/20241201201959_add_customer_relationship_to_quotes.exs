defmodule ExCommerce.Repo.Migrations.AddCustomerRelationshipToQuotes do
  use Ecto.Migration

  def change do
    alter table(:quotes) do
      add :customer_id, references(:customers, type: :uuid, on_delete: :delete_all), null: true
    end
  end
end
