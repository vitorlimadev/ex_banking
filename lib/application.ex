defmodule ExBanking.Application do
  use Application

  alias ExBanking.Users.UserDynamicSupervisor

  def start(_, _) do
    Supervisor.start_link(
      [
        {UserDynamicSupervisor, []}
      ],
      strategy: :one_for_one,
      name: ExBanking.DynamicSupervisor
    )
  end
end
