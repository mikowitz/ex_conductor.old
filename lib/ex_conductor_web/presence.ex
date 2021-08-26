defmodule ExConductorWeb.Presence do
  use Phoenix.Presence,
    otp_app: :ex_conductor,
    pubsub_server: ExConductor.PubSub

  alias ExConductor.Accounts.User

  def ensemble_topic, do: "ensemble:members"

  def instrument_list do
    ensemble_topic()
    |> list()
    |> Enum.map(fn {user_id, %{metas: metas}} ->
      {user_id, List.first(metas)}
    end)
    |> Enum.into(%{})
  end

  def for_user(%User{} = user) do
    instrument_list()
    |> Map.get(to_string(user.id), %{})
    |> Map.get(:instrument, nil)
  end

  def for_user(_), do: nil

  def next_index_for(instrument) do
    count_for(instrument) + 1
  end

  def count_for(instrument) do
    instrument_list()
    |> Map.values()
    |> Enum.count(fn map -> map[:instrument][:instrument] == instrument end)
  end

  def reindex do
    instruments =
      instrument_list()
      |> Map.values()
      |> Enum.map(& &1[:instrument][:instrument])
      |> Enum.uniq()
  end
end
