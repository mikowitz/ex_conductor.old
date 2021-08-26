defmodule ExConductorWeb.CurrentEnsembleComponent do
  use ExConductorWeb, :live_component

  def render(assigns) do
    ~L"""
    <h3>Current ensemble</h3>
    <ul>
    <%= for {_, %{label: label}} <- @ensemble do %>
      <li><%= inspect label %></li>
    <% end %>
    </ul>
    """
  end
end
