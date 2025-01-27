defmodule BankEventSourcing.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :account_id, :string
    field :event_type, :string
    field :data, :map
    field :metadata, :map
    field :version, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:account_id, :event_type, :data, :metadata, :version])
    |> validate_required([:account_id, :event_type, :data, :metadata, :version])
  end
end
