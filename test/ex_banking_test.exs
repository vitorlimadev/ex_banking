defmodule ExBankingTest do
  use ExUnit.Case, async: true
  doctest ExBanking

  describe "create_user/1" do
    test "creates a user's UserGenServer" do
      assert :ok = ExBanking.create_user("Anti-mage")
    end

    test "fails if a UserGenServer with the same name is already registered" do
      assert :ok = ExBanking.create_user("Meepo")
      assert {:error, :user_already_exists} = ExBanking.create_user("Meepo")
    end
  end

  describe "deposit/3" do
    test "adds multiple currencies to a user with the correct balance" do
      ExBanking.create_user("Mirana")

      assert {:ok, 1.0} = ExBanking.deposit("Mirana", 1.0, "BTC")
      assert {:ok, 50.0} = ExBanking.deposit("Mirana", 50.0, "USD")
      assert {:ok, 100.0} = ExBanking.deposit("Mirana", 50.0, "USD")
      assert {:ok, 1.03} = ExBanking.deposit("Mirana", 0.03, "BTC")
    end

    test "fails if user doesn't exist" do
      assert {:error, :user_does_not_exist} = ExBanking.deposit("Leona", 0.50, "SOL")
    end
  end

  describe "withdraw/3" do
    test "removes the right amount of the right currency from a user" do
      ExBanking.create_user("Luna")

      ExBanking.deposit("Luna", 100.0, "USD")
      ExBanking.deposit("Luna", 1.0, "BTC")

      assert {:ok, 90.0} = ExBanking.withdraw("Luna", 10.0, "USD")
      assert {:ok, 89.32} = ExBanking.withdraw("Luna", 0.68, "USD")
      assert {:ok, 0.9} = ExBanking.withdraw("Luna", 0.1, "BTC")
      assert {:ok, 0.2} = ExBanking.withdraw("Luna", 0.7, "BTC")
    end

    test "returns a two point precision float number" do
      ExBanking.create_user("Morphling")

      ExBanking.deposit("Morphling", 1.0, "BTC")

      {:ok, new_amount} = ExBanking.withdraw("Morphling", 0.79, "BTC")

      assert new_amount != 0.21000000000000008
      assert new_amount == 0.21
    end

    test "fails if user doesn't have enough money" do
      ExBanking.create_user("Pudge")

      ExBanking.deposit("Pudge", 0.01, "USD")

      assert {:error, :not_enough_money} = ExBanking.withdraw("Pudge", 9_999_999.9, "USD")
      assert {:error, :not_enough_money} = ExBanking.withdraw("Pudge", 0.02, "USD")
      assert {:ok, 0.0} = ExBanking.withdraw("Pudge", 0.01, "USD")
    end

    test "fails if user doesn't exist" do
      assert {:error, :user_does_not_exist} = ExBanking.withdraw("Nami", 200.0, "WAVE")
    end
  end

  describe "get_balance/3" do
    test "gets the right user's balance for the right currency" do
      ExBanking.create_user("Lina")

      assert {:ok, 0.0} = ExBanking.get_balance("Lina", "USD")

      ExBanking.deposit("Lina", 10.0, "USD")

      assert {:ok, 10.0} = ExBanking.get_balance("Lina", "USD")
    end

    test "fails if user doesn't exist" do
      assert {:error, :user_does_not_exist} = ExBanking.get_balance("Garen", "DEMA")
    end
  end

  describe "send/4" do
    test "transacts from one user's currency balance to another" do
      ExBanking.create_user("Invoker")
      ExBanking.create_user("Axe")
      ExBanking.create_user("Visage")

      ExBanking.deposit("Invoker", 50.0, "EUR")
      ExBanking.deposit("Invoker", 0.1, "BTC")

      assert {:ok, 40.0, 10.0} = ExBanking.send("Invoker", "Axe", 10.0, "EUR")
      assert {:ok, 0.08, 0.02} = ExBanking.send("Invoker", "Visage", 0.02, "BTC")

      ExBanking.deposit("Axe", 1.0, "BTC")

      assert {:ok, 6.0, 4.0} = ExBanking.send("Axe", "Visage", 4.0, "EUR")
      assert {:ok, 0.01, 1.01} = ExBanking.send("Visage", "Axe", 0.01, "BTC")
    end

    test "fails if the sending user don't have enough of the right currency" do
      ExBanking.create_user("Alchemist")
      ExBanking.create_user("Pangolier")

      ExBanking.deposit("Alchemist", 100.0, "EUR")

      assert {:error, :not_enough_money} = ExBanking.send("Alchemist", "Pangolier", 1.0, "USD")
      assert {:error, :not_enough_money} = ExBanking.send("Alchemist", "Pangolier", 1.0, "BTC")
      assert {:ok, 99.0, 1.0} = ExBanking.send("Alchemist", "Pangolier", 1.0, "EUR")
    end

    test "fails if the sending user don't exist" do
      ExBanking.create_user("Legion Commander")

      assert {:error, :sender_does_not_exist} = ExBanking.send("Ashe", "Legion Commander", 1.0, "EUR")
    end

    test "fails if the recieving user don't exist" do
      ExBanking.create_user("Zeus")

      assert {:error, :reciever_does_not_exist} = ExBanking.send("Zeus", "Katarina", 1.0, "EUR")
    end
  end
end
