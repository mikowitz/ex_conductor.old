defmodule ExConductorWeb.CurrentEnsembleComponent do
  use ExConductorWeb, :live_component

  def mount(socket) do
    IO.inspect(socket.assigns)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h3>Current ensemble</h3>
    <ul>
    <%= for {_, %{metas: [inst|_]}} <- @ensemble do %>
      <li><%= inst[:instrument] %></li>
    <% end %>
    </ul>
    """
  end
end
