defmodule BankEventSourcing.EventStore do
  use GenServer
  alias BankEventSourcing.{Repo, Event}
  import Ecto.Query

  # Client API
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def append_event(event) do
    GenServer.call(__MODULE__, {:append_event, event})
  end

  def get_events(account_id) do
    GenServer.call(__MODULE__, {:get_events, account_id})
  end

  # Server callbacks
  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:append_event, event}, _from, state) do
    event_type = event.__struct__ |> to_string()

    # Get the current version for the account
    current_version =
      from(e in Event,
        where: e.account_id == ^event.account_id,
        select: max(e.version)
      )
      |> Repo.one() || 0

    new_version = current_version + 1

    event_record = %Event{
      account_id: event.account_id,
      event_type: event_type,
      data: Map.from_struct(event),
      metadata: %{
        timestamp: DateTime.utc_now()
      },
      version: new_version
    }

    case Repo.insert(event_record) do
      {:ok, _record} -> {:reply, :ok, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:get_events, account_id}, _from, state) do
    events =
      from(e in Event,
        where: e.account_id == ^account_id,
        order_by: [asc: e.version]
      )
      |> Repo.all()
      |> Enum.map(&deserialize_event/1)

    {:reply, {:ok, events}, state}
  end

  defp deserialize_event(event_record) do
    module = String.to_existing_atom(event_record.event_type)
    struct(module, event_record.data)
  end
end
