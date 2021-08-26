defmodule ExConductorWeb.ScoreComponent do
  use ExConductorWeb, :live_component

  def render(assigns) do
    if assigns.score do
      ~L"""
      <hr/>
      <img class="score" src="data:image/png;base64,<%= raw @score %>" alt="score" />
      <hr/>
      """
    else
      ~L"""
      """
    end
  end
end
