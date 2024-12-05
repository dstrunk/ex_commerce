defmodule ExCommerce.Repo.Migrations.AddUserRelationships do
  use Ecto.Migration

  def change do
    alter table(:quotes) do
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: true
    end
  end
end
