defmodule ExConductorWeb.JoinEnsembleComponent do
  use ExConductorWeb, :live_component

  def render(assigns) do
    ~L"""
    <form id="join-ensemble" phx-submit="register_instrument">
      <input type="text" name="instrument" placeholder="What instrument are you playing?" autocomplete="off" /?>
      <button type="submit" phx-disable-with="Joining...">Join ensemble</button>
    </form>
    """
  end
end
