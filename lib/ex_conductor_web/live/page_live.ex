defmodule ExConductorWeb.PageLive do
  use ExConductorWeb, :live_view

  alias ExConductor.Accounts
  alias ExConductor.Accounts.User
  alias ExConductor.EnsembleRegistry
  alias ExConductorWeb.Presence

  alias ExConductorWeb.JoinEnsembleComponent
  alias ExConductorWeb.EnsembleMemberComponent
  alias ExConductorWeb.CurrentEnsembleComponent

  @impl true
  def mount(_params, session, socket) do
    ExConductorWeb.Endpoint.subscribe(Presence.ensemble_topic())

    socket =
      add_user(socket, session)
      |> assign_ensemble()
      |> assign_instrument()

    {:ok, socket}
  end

  @impl true
  def handle_event("register_instrument", %{"instrument" => instrument}, socket) do
    send(self(), :after_register)

    inst = EnsembleRegistry.add(socket.assigns.current_user.id, instrument)

    {:noreply, assign(socket, instrument: inst)}
  end

  @impl true
  def handle_event("change_instrument", _, socket) do
    send(self(), :after_change)

    EnsembleRegistry.remove(socket.assigns.current_user.id)
    {:noreply, assign(socket, instrument: nil)}
  end

  @impl true

  def handle_info(:after_register, socket) do
    ExConductorWeb.Endpoint.broadcast!(Presence.ensemble_topic(), "ensemble_change", %{})
    {:noreply, socket}
  end

  def handle_info(:after_change, socket) do
    ExConductorWeb.Endpoint.broadcast!(Presence.ensemble_topic(), "ensemble_change", %{})
    {:noreply, socket}
  end

  def handle_info(%{event: "ensemble_change", payload: _payload}, socket) do
    socket =
      socket
      |> assign_ensemble()
      |> assign_instrument()

    {:noreply, assign_ensemble(socket)}
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

  defp assign_ensemble(socket) do
    assign(socket, ensemble: EnsembleRegistry.ensemble())
  end

  def assign_instrument(%{assigns: %{current_user: %User{} = user}} = socket) do
    assign(
      socket,
      instrument: EnsembleRegistry.for_user(user.id)
    )
  end

  def assign_instrument(socket) do
    socket
  end
end
