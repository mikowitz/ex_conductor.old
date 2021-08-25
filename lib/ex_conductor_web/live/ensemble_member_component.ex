defmodule ExConductorWeb.EnsembleMemberComponent do
  use ExConductorWeb, :live_component

  def render(assigns) do
    ~L"""
    You are playing <b><%= @instrument %></b>

    <button id="change-instrument" phx-click="change_instrument">Change instrument</button>

    """
  end
end
