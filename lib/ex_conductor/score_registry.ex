defmodule ExConductor.ScoreRegistry do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, nil}
  end

  def set(score) do
    GenServer.cast(__MODULE__, {:set, score})
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  def clear do
    GenServer.cast(__MODULE__, :clear)
  end

  def handle_cast({:set, score}, _state), do: {:noreply, score}

  def handle_cast(:clear, _), do: {:noreply, nil}

  def handle_call(:get, _, score), do: {:reply, score, score}
end
