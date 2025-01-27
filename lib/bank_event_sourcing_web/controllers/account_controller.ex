defmodule BankEventSourcingWeb.AccountController do
  use BankEventSourcingWeb, :controller
  alias BankEventSourcing.AccountManager

  def create(conn, %{"account_id" => account_id, "initial_balance" => initial_balance}) do
    case AccountManager.create_account(account_id, initial_balance) do
      {:ok, account} ->
        json(conn, account)
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  def deposit(conn, %{"account_id" => account_id, "amount" => amount}) do
    case AccountManager.deposit(account_id, amount) do
      {:ok, account} ->
        json(conn, account)
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  def withdraw(conn, %{"account_id" => account_id, "amount" => amount}) do
    case AccountManager.withdraw(account_id, amount) do
      {:ok, account} ->
        json(conn, account)
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  def show(conn, %{"account_id" => account_id}) do
    case AccountManager.get_account(account_id) do
      {:ok, account} ->
        json(conn, account)
      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: reason})
    end
  end
end
