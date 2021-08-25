defmodule ExConductorWeb.PageLive do
  use ExConductorWeb, :live_view

  alias ExConductor.Accounts
  alias ExConductor.Accounts.User
  alias ExConductorWeb.Presence

  alias ExConductorWeb.JoinEnsembleComponent
  alias ExConductorWeb.EnsembleMemberComponent
  alias ExConductorWeb.CurrentEnsembleComponent

  @impl true
  def mount(_params, session, socket) do
    ExConductorWeb.Endpoint.subscribe(Presence.ensemble_topic())

    socket =
      add_user(socket, session)
      |> assign_presence()

    {:ok, assign(socket, instrument: Presence.for_user(socket.assigns.current_user)[:instrument])}
  end

  @impl true
  def handle_event("register_instrument", %{"instrument" => instrument}, socket) do
    send(self(), :after_register)
    {:noreply, assign(socket, instrument: instrument)}
  end

  @impl true
  def handle_event("change_instrument", _, socket) do
    send(self(), :after_change)
    socket = assign_presence(socket)
    {:noreply, assign(socket, instrument: nil)}
  end

  @impl true
  def handle_info(:after_register, socket) do
    Presence.track(
      self(),
      Presence.ensemble_topic(),
      to_string(socket.assigns.current_user.id),
      %{instrument: socket.assigns.instrument}
    )

    {:noreply, assign_presence(socket)}
  end

  def handle_info(:after_change, socket) do
    Presence.untrack(
      self(),
      Presence.ensemble_topic(),
      to_string(socket.assigns.current_user.id)
    )

    socket = assign_presence(socket)
    {:noreply, assign(socket, instrument: nil)}
  end

  def handle_info(%{event: "presence_diff", payload: payload}, socket) do
    IO.inspect(payload)
    {:noreply, assign_presence(socket)}
  end

  defp add_user(socket, session) do
    assign(socket, current_user: get_current_user(session))
  end

  defp get_current_user(%{"user_token" => user_token}) do
    case Accounts.get_user_by_session_token(user_token) do
      %User{} = user -> user
      _ -> nil
    end
  end

  defp get_current_user(_), do: nil

  defp assign_presence(socket) do
    assign(socket, ensemble: Presence.list(Presence.ensemble_topic()))
  end
end
