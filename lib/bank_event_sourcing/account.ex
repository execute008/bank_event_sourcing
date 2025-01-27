defmodule BankEventSourcing.Account do
  alias BankEventSourcing.Events.{AccountCreated, MoneyDeposited, MoneyWithdrawn}

  @derive {Jason.Encoder, only: [:account_id, :balance, :version]}
  defstruct [:account_id, :balance, :version]

  # Command handlers
  def create_account(account_id, initial_balance) when initial_balance >= 0 do
    %AccountCreated{
      account_id: account_id,
      initial_balance: initial_balance,
      timestamp: DateTime.utc_now()
    }
  end

  @spec deposit(any(), any()) :: %BankEventSourcing.Events.MoneyDeposited{
          account_id: any(),
          amount: any(),
          timestamp: DateTime.t()
        }
  def deposit(account, amount) when amount > 0 do
    %MoneyDeposited{
      account_id: account.account_id,
      amount: amount,
      timestamp: DateTime.utc_now()
    }
  end

  def withdraw(%__MODULE__{balance: balance} = account, amount)
      when amount > 0 and balance >= amount do
    %MoneyWithdrawn{
      account_id: account.account_id,
      amount: amount,
      timestamp: DateTime.utc_now()
    }
  end

  def withdraw(%__MODULE__{balance: balance} = _, amount) when amount > 0 and balance < amount, do: {:error, "Insufficient funds"}

  def withdraw(_, _), do: {:error, "Invalid amount"}



  # State mutators (apply events)
  def apply_event(%AccountCreated{account_id: account_id, initial_balance: initial_balance}, _state) do
    %__MODULE__{
      account_id: account_id,
      balance: initial_balance,
      version: 1
    }
  end

  def apply_event(%MoneyDeposited{amount: amount}, %__MODULE__{} = state) do
    %{state |
      balance: state.balance + amount,
      version: state.version + 1
    }
  end

  def apply_event(%MoneyWithdrawn{amount: amount}, %__MODULE__{} = state) do
    %{state |
      balance: state.balance - amount,
      version: state.version + 1
    }
  end
end
