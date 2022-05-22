defmodule ExBanking.Users.UserDynamicSupervisor do
  @moduledoc """
  Users dynamic supervisor.

  This module is responsible for supervising the creation
  of one ExBanking.Users.UserGenServer per user dynamically
  at runtime.
  """

  use DynamicSupervisor

  def start_link(_),
    do: DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

  @impl true
  def init(_), do: DynamicSupervisor.init(strategy: :one_for_one)
end
