defmodule BankEventSourcingWeb.Router do
  use BankEventSourcingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BankEventSourcingWeb do
    pipe_through :api

    post "/accounts", AccountController, :create
    get "/accounts/:account_id", AccountController, :show
    post "/accounts/:account_id/deposit", AccountController, :deposit
    post "/accounts/:account_id/withdraw", AccountController, :withdraw
  end
end
