defmodule ExBanking.ValidationsTest do
  use ExUnit.Case

  alias ExBanking.Validations

  @error_tuple {:error, :wrong_arguments}

  doctest ExBanking.Validations

  test "validate_user/1" do
    assert Validations.validate_user("a") == :ok
    assert Validations.validate_user("Joe") == :ok

    assert Validations.validate_user("") == @error_tuple
    assert Validations.validate_user(nil) == @error_tuple
    assert Validations.validate_user(0) == @error_tuple
    assert Validations.validate_user({}) == @error_tuple
    assert Validations.validate_user([]) == @error_tuple
  end

  test "validate_currency_amount/1" do
    assert Validations.validate_currency_amount(0.0) == {:ok, 0.00}
    assert Validations.validate_currency_amount(1.0) == {:ok, 1.00}
    assert Validations.validate_currency_amount(1.1) == {:ok, 1.10}
    assert Validations.validate_currency_amount(1.25334534534) == {:ok, 1.25}
    assert Validations.validate_currency_amount(9_993_847.8133453458548934) == {:ok, 9_993_847.81}

    assert Validations.validate_currency_amount(0) == @error_tuple
    assert Validations.validate_currency_amount(1) == @error_tuple
    assert Validations.validate_currency_amount(-0.1) == @error_tuple
    assert Validations.validate_currency_amount("") == @error_tuple
    assert Validations.validate_currency_amount(nil) == @error_tuple
    assert Validations.validate_currency_amount({}) == @error_tuple
    assert Validations.validate_currency_amount([]) == @error_tuple
  end

  test "validate_currency/1" do
    assert Validations.validate_currency("A") == :ok
    assert Validations.validate_currency("BTC") == :ok

    assert Validations.validate_currency("") == @error_tuple
    assert Validations.validate_currency(nil) == @error_tuple
    assert Validations.validate_currency(0) == @error_tuple
    assert Validations.validate_currency({}) == @error_tuple
    assert Validations.validate_currency([]) == @error_tuple
  end
end
