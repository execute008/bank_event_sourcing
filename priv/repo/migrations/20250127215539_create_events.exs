defmodule BankEventSourcing.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :account_id, :string, null: false
      add :event_type, :string, null: false
      add :data, :map, null: false
      add :metadata, :map, null: false
      add :version, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:events, [:account_id])
    create unique_index(:events, [:account_id, :version])
  end
end
