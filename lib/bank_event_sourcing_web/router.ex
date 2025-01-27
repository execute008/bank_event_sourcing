defmodule BankEventSourcingWeb.Router do
  use BankEventSourcingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BankEventSourcingWeb do
    pipe_through :api
  end
end
