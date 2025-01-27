defmodule BankEventSourcing.AccountManager do
  use GenServer
  alias BankEventSourcing.{Account, EventStore}

  # Client API
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def create_account(account_id, initial_balance) do
    GenServer.call(__MODULE__, {:create_account, account_id, initial_balance})
  end

  def deposit(account_id, amount) do
    GenServer.call(__MODULE__, {:deposit, account_id, amount})
  end

  def withdraw(account_id, amount) do
    GenServer.call(__MODULE__, {:withdraw, account_id, amount})
  end

  def get_account(account_id) do
    GenServer.call(__MODULE__, {:get_account, account_id})
  end

  # Server callbacks
  @impl true
  def init(_) do
    {:ok, %{accounts: %{}}}
  end

  @impl true
  def handle_call({:create_account, account_id, initial_balance}, _from, state) do
    event = Account.create_account(account_id, initial_balance)
    EventStore.append_event(event)
    account = Account.apply_event(event, nil)
    {:reply, {:ok, account}, put_in(state.accounts[account_id], account)}
  end

  @impl true
  def handle_call({:deposit, account_id, amount}, _from, state) do
    with {:ok, account} <- get_account_from_state(state, account_id),
         event <- Account.deposit(account, amount) do
      EventStore.append_event(event)
      updated_account = Account.apply_event(event, account)
      {:reply, {:ok, updated_account}, put_in(state.accounts[account_id], updated_account)}
    else
      error -> {:reply, error, state}
    end
  end

  @impl true
  def handle_call({:withdraw, account_id, amount}, _from, state) do
    with {:ok, account} <- get_account_from_state(state, account_id),
         result <- Account.withdraw(account, amount) do
      case result do
        {:error, reason} ->
          {:reply, {:error, reason}, state}
        event ->
          EventStore.append_event(event)
          updated_account = Account.apply_event(event, account)
          {:reply, {:ok, updated_account}, put_in(state.accounts[account_id], updated_account)}
      end
    else
      error -> {:reply, error, state}
    end
  end

  @impl true
  def handle_call({:get_account, account_id}, _from, state) do
    result = get_account_from_state(state, account_id)
    {:reply, result, state}
  end

  defp get_account_from_state(state, account_id) do
    case Map.get(state.accounts, account_id) do
      nil -> {:error, :account_not_found}
      account -> {:ok, account}
    end
  end
end
