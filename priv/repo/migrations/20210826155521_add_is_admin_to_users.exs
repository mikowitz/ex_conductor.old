defmodule ExConductor.Repo.Migrations.AddIsAdminToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:is_admin, :boolean, null: false, default: false)
    end

    create(index(:users, [:is_admin]))
  end
end
