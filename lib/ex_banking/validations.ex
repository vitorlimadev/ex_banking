defmodule ExBanking.Validations do
  @moduledoc "Domain validation functions"

  @error_tuple {:error, :wrong_arguments}
  @type error_tuple :: {:error, :wrong_arguments}

  @spec validate_user(user :: String.t()) :: :ok | error_tuple
  def validate_user(user) when is_binary(user) do
    if String.length(user) > 0 do
      :ok
    else
      @error_tuple
    end
  end

  def validate_user(_), do: {:error, :wrong_arguments}

  @spec validate_currency_amount(amount :: number()) :: {:ok, number()} | error_tuple
  def validate_currency_amount(amount) when is_number(amount) and amount >= 0,
    do: {:ok, Float.round(amount / 1, 2)}

  def validate_currency_amount(_), do: @error_tuple

  @spec validate_currency(currency :: String.t()) :: :ok | error_tuple
  def validate_currency(currency) when is_binary(currency) do
    if String.length(currency) > 0 do
      :ok
    else
      @error_tuple
    end
  end

  def validate_currency(_), do: @error_tuple
end
