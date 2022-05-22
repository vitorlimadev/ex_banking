defmodule ExBanking do
  @moduledoc """
  ExBanking domain functions.

  This module is responsible for validating all inputs
  and executing the Users domain functions to handle user
  creation and transactions.
  """

  import ExBanking.Validations

  alias ExBanking.Users

  @doc """
  See `ExBanking.Users.create/1`

  """
  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) do
    with :ok <- validate_user(user),
         {:ok, :user_created} <- Users.create(user) do
      :ok
    end
  end

  @doc """
  See `ExBanking.Users.deposit/3`

  """
  @spec deposit(user :: String.t(), amount :: number(), currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) do
    with :ok <- validate_user(user),
         :ok <- validate_currency(currency),
         {:ok, parsed_amount} <- validate_currency_amount(amount),
         {:ok, user_pid} <- Users.fetch(user) do
      Users.deposit(user_pid, parsed_amount, currency)
    end
  end

  @doc """
  See `ExBanking.Users.withdraw/3`

  """
  @spec withdraw(user :: String.t(), amount :: number(), currency :: String.t()) ::
          {:ok, new_balance :: number()}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(user, amount, currency) do
    with :ok <- validate_user(user),
         :ok <- validate_currency(currency),
         {:ok, parsed_amount} <- validate_currency_amount(amount),
         {:ok, user_pid} <- Users.fetch(user) do
      Users.withdraw(user_pid, parsed_amount, currency)
    end
  end

  @doc """
  See `ExBanking.Users.get_balance/1`

  """
  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number()}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    with :ok <- validate_user(user),
         :ok <- validate_currency(currency),
         {:ok, user_pid} <- Users.fetch(user) do
      Users.get_balance(user_pid, currency)
    end
  end

  @doc """
  See `ExBanking.Users.send/4`

  """
  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number(),
          currency :: String.t()
        ) ::
          {:ok, from_user_balance :: number(), to_user_balance :: number()}
          | {:error,
             :wrong_arguments
             | :not_enough_money
             | :sender_does_not_exist
             | :receiver_does_not_exist
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency) do
    with {:from_user_valid?, :ok} <- {:from_user_valid?, validate_user(from_user)},
         {:to_user_valid?, :ok} <- {:to_user_valid?, validate_user(to_user)},
         {:from_user_exists?, {:ok, from_user_pid}} <-
           {:from_user_exists?, Users.fetch(from_user)},
         {:to_user_exists?, {:ok, to_user_pid}} <- {:to_user_exists?, Users.fetch(to_user)},
         :ok <- validate_currency(currency),
         {:ok, parsed_amount} <- validate_currency_amount(amount) do
      Users.send(from_user_pid, to_user_pid, parsed_amount, currency)
    else
      {:from_user_exists?, _} -> {:error, :sender_does_not_exist}
      {:to_user_exists?, _} -> {:error, :reciever_does_not_exist}
      error -> error
    end
  end
end
