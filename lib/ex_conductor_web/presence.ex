defmodule ExConductorWeb.Presence do
  use Phoenix.Presence,
    otp_app: :ex_conductor,
    pubsub_server: ExConductor.PubSub

  def ensemble_topic, do: "ensemble:members"
  def ensemble_admin_topic, do: "ensemble:admin"
end
