defmodule BankEventSourcing.Repo do
  use Ecto.Repo,
    otp_app: :bank_event_sourcing,
    adapter: Ecto.Adapters.Postgres
end
