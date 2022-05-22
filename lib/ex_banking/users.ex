defmodule ExBanking.Users do
  @moduledoc """
  Users domain functions.

  Fore every user, we dynamically create a GenServer process 
  supervised by ExBanking.Users.UserDynamicSupervisor.

  All user GenServers are identified by the user name.

  See `ExBanking.Users.UserGenServer`
  """

  alias ExBanking.Users.UserDynamicSupervisor
  alias ExBanking.Users.UserGenServer

  @concurrent_transactions_limit 10

  @doc """
  Creates a new user by starting a UserGenServer to handle
  this User's state in runtime.

  """
  @spec create(user :: String.t()) :: {:ok, :user_created} | {:error, :user_already_exists}
  def create(user) do
    case DynamicSupervisor.start_child(
           UserDynamicSupervisor,
           {UserGenServer, user}
         ) do
      {:ok, _pid} ->
        {:ok, :user_created}

      {:error, {:already_started, _}} ->
        {:error, :user_already_exists}
    end
  end

  @doc """
  Fetches a user by searching for a running UserGenServer
  with his name.

  If a User is found, returns {:ok, pid()}, where pid() is
  the PID of the user's ExBanking.Users.UserGenServer.

  """
  @spec fetch(user :: String.t()) :: {:ok, user_pid :: pid()} | {:error, :user_does_not_exist}
  def fetch(name) do
    case :global.whereis_name(name) do
      :undefined ->
        {:error, :user_does_not_exist}

      user_pid ->
        {:ok, user_pid}
    end
  end

  @doc """
  Deposits an amount of a specific currency on a user's account.

  Fails if user has more pending transactions than the maximum
  concurrent transaction per user limit.

  """
  @spec deposit(user_pid :: pid(), amount :: number(), currency :: String.t()) ::
          {:ok, new_amount :: number} | {:error, :too_many_requests_to_user}
  def deposit(user_pid, amount, currency) do
    if transaction_schedule_available?(user_pid) do
      UserGenServer.call_deposit(user_pid, amount, currency)
    else
      {:error, :too_many_requests_to_user}
    end
  end

  @doc """
  Withdraws an amount of a specific currency on a user's account.

  Fails if user has more pending transactions than the maximum
  concurrent transaction per user limit.

  """
  @spec withdraw(user_pid :: pid(), amount :: number(), currency :: String.t()) ::
          {:ok, new_amount :: number} | {:error, :not_enough_money | :too_many_requests_to_user}
  def withdraw(user_pid, amount, currency) do
    if transaction_schedule_available?(user_pid) do
      UserGenServer.call_withdraw(user_pid, amount, currency)
    else
      {:error, :too_many_requests_to_user}
    end
  end

  @doc """
  Get's a user balance of a specific currency.

  """
  @spec get_balance(user_pid :: pid(), currency :: String.t()) ::
          {:ok, balance :: number()} | {:error, :too_many_requests_to_user}
  def get_balance(user_pid, currency) do
    if transaction_schedule_available?(user_pid) do
      UserGenServer.call_get_balance(user_pid, currency)
    else
      {:error, :too_many_requests_to_user}
    end
  end

  @doc """
  Transfers a user's money to another user.

  """
  @spec send(
          from_user_pid :: pid(),
          to_user_pid :: pid(),
          amount :: number(),
          currency :: String.t()
        ) ::
          {:ok, from_user_balance :: number(), to_user_balance :: number()}
          | {:error,
             :not_enough_money
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver}
  def send(from_user_pid, to_user_pid, amount, currency) do
    with {:from_user_available?, true} <-
           {:from_user_available?, transaction_schedule_available?(from_user_pid)},
         {:to_user_available?, true} <-
           {:to_user_available?, transaction_schedule_available?(to_user_pid)},
         {:ok, new_sender_amount} <- withdraw(from_user_pid, amount, currency),
         {:ok, new_receiver_amount} <- deposit(to_user_pid, amount, currency) do
      {:ok, new_sender_amount, new_receiver_amount}
    else
      {:from_user_available?, false} ->
        {:error, :too_many_requests_to_sender}

      {:to_user_available?, false} ->
        {:error, :too_many_requests_to_receiver}

      error ->
        error
    end
  end

  defp transaction_schedule_available?(user_pid) do
    gen_server_info = Process.info(user_pid)

    case Keyword.get(gen_server_info, :message_queue_len) do
      transactions when transactions < @concurrent_transactions_limit ->
        true

      _ ->
        false
    end
  end
end
