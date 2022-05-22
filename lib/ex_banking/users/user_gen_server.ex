defmodule ExBanking.Users.UserGenServer do
  @moduledoc """
  An individual user GenServer responsible for managing the
  user's state.

  All users have their own GenServer, and all UserGenServers are
  identified by the user name. The GenServer's name is stored
  globally, and its PID can be fetched by the :global module.

  See `https://www.erlang.org/doc/man/global.html`
  """

  use GenServer

  @doc """
  Deposit handler helper function.

  """
  @spec call_deposit(pid(), amount :: number(), currency :: String.t()) ::
          {:ok, new_amount :: number}
  def call_deposit(pid, amount, currency) do
    GenServer.call(pid, {:deposit, amount, currency})
  end

  @doc """
  Withdraw handler helper function.

  """
  @spec call_withdraw(pid(), amount :: float(), currency :: String.t()) ::
          {:ok, new_amount :: number} | {:error, :not_enough_money}
  def call_withdraw(pid, amount, currency) do
    GenServer.call(pid, {:withdraw, amount, currency})
  end

  @doc """
  Get user's balance handler helper function.

  """
  @spec call_get_balance(pid(), currency :: String.t()) ::
          {:ok, new_amount :: number}
  def call_get_balance(pid, currency) do
    GenServer.call(pid, {:get_balance, currency})
  end

  # GenServer functions

  def start_link(name),
    do: GenServer.start_link(__MODULE__, [], name: {:global, name})

  def init(_), do: {:ok, %{}}

  def handle_call({:deposit, amount, currency}, _, state) do
    new_amount = Float.round(amount + (state[currency] || 0.0), 2)

    {:reply, {:ok, new_amount}, Map.put(state, currency, new_amount)}
  end

  def handle_call({:withdraw, amount, currency}, _from, state) do
    new_amount = (state[currency] || 0.0) - amount

    case new_amount do
      n when n >= 0 ->
        {:reply, {:ok, Float.round(n, 2)}, Map.put(state, currency, n)}

      _ ->
        {:reply, {:error, :not_enough_money}, state}
    end
  end

  def handle_call({:get_balance, currency}, _, state) do
    {:reply, {:ok, state[currency] || 0.0}, state}
  end
end
