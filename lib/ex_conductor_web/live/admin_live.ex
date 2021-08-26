defmodule ExConductorWeb.AdminLive do
  use ExConductorWeb, :live_view

  alias ExConductor.{EnsembleRegistry, Lilypond, ScoreRegistry}
  alias ExConductorWeb.Presence

  alias ExConductorWeb.ScoreComponent
  alias ExConductorWeb.CurrentEnsembleComponent

  def mount(_, _, socket) do
    ExConductorWeb.Endpoint.subscribe(Presence.ensemble_admin_topic())
    socket = assign(socket, score: ScoreRegistry.get(), ensemble: EnsembleRegistry.ensemble())

    {:ok, socket}
  end

  def handle_event("generate-score", _, socket) do
    instruments =
      EnsembleRegistry.ensemble()
      |> Enum.map(fn {_, %{label: label}} -> label end)

    socket =
      socket
      |> put_flash(:info, "Score is being generated for #{inspect(instruments)}")

    send(self(), :after_generate)

    {:noreply, socket}
  end

  def handle_event("clear-score", _, socket) do
    socket =
      socket
      |> assign(score: nil)

    send(self(), :after_clear)

    {:noreply, socket}
  end

  def handle_info(:after_generate, socket) do
    instruments =
      EnsembleRegistry.ensemble()
      |> Enum.map(fn {_, %{label: label}} -> label end)

    score = Lilypond.generate_score(instruments)

    ScoreRegistry.set(score)

    socket =
      socket
      |> assign(score: score)
      |> put_flash(:info, "Score has been generated for #{inspect(instruments)}")

    ExConductorWeb.Endpoint.broadcast!(Presence.ensemble_topic(), "generated_score", %{
      score: score
    })

    ExConductorWeb.Endpoint.broadcast!(Presence.ensemble_admin_topic(), "generated_score", %{
      score: score
    })

    {:noreply, socket}
  end

  def handle_info(:after_clear, socket) do
    ExConductorWeb.Endpoint.broadcast!(Presence.ensemble_topic(), "cleared_score", %{})
    ExConductorWeb.Endpoint.broadcast!(Presence.ensemble_admin_topic(), "cleared_score", %{})

    ScoreRegistry.clear()

    {:noreply, assign(socket, score: nil)}
  end

  def handle_info(%{event: "ensemble_change", payload: _payload}, socket) do
    socket = assign(socket, ensemble: EnsembleRegistry.ensemble())

    {:noreply, socket}
  end

  def handle_info(%{event: "query_score"}, socket) do
    ExConductorWeb.Endpoint.broadcast!(Presence.ensemble_topic(), "generated_score", %{
      score: socket.assigns.score
    })

    {:noreply, socket}
  end

  def handle_info(%{event: "generated_score", payload: %{score: score}}, socket) do
    {:noreply, assign(socket, score: score)}
  end

  def handle_info(%{event: "cleared_score"}, socket) do
    {:noreply, assign(socket, score: nil)}
  end

  def handle_params(_params, _, socket) do
    {:noreply, socket}
  end
end
