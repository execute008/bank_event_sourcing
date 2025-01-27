defmodule BankEventSourcing.Events do
  defmodule AccountCreated do
    defstruct [:account_id, :initial_balance, :timestamp]
  end

  defmodule MoneyDeposited do
    defstruct [:account_id, :amount, :timestamp]
  end

  defmodule MoneyWithdrawn do
    defstruct [:account_id, :amount, :timestamp]
  end
end
