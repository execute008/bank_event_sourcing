defmodule BankEventSourcing.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BankEventSourcingWeb.Telemetry,
      BankEventSourcing.Repo,
      {DNSCluster, query: Application.get_env(:bank_event_sourcing, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BankEventSourcing.PubSub},
      BankEventSourcingWeb.Endpoint,
      BankEventSourcing.AccountManager,
      BankEventSourcing.EventStore
    ]

    opts = [strategy: :one_for_one, name: BankEventSourcing.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    BankEventSourcingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
