defmodule ExConductorWeb.Presence do
  use Phoenix.Presence,
    otp_app: :ex_conductor,
    pubsub_server: ExConductor.PubSub

  alias ExConductor.Accounts.User

  def ensemble_topic, do: "ensemble:members"

  def for_user(%User{} = user) do
    metas =
      ensemble_topic()
      |> list()
      |> Map.get(to_string(user.id), %{})
      |> Map.get(:metas)

    case metas do
      nil -> nil
      [] -> nil
      [meta | _] -> meta
    end
  end

  def for_user(_), do: nil
end
