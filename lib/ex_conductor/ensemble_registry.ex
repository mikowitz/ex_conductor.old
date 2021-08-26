defmodule ExConductor.EnsembleRegistry do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def for_user(id) when is_integer(id) do
    GenServer.call(__MODULE__, {:for_user, id})
  end

  def for_user(_), do: nil

  def add(id, instrument) do
    GenServer.call(__MODULE__, {:add, id, instrument})
  end

  def remove(id) do
    GenServer.cast(__MODULE__, {:remove, id})
  end

  def ensemble do
    GenServer.call(__MODULE__, :ensemble)
  end

  def reset! do
    GenServer.cast(__MODULE__, :reset!)
  end

  def handle_call({:for_user, id}, _, ensemble) do
    {:reply, Map.get(ensemble, id), ensemble}
  end

  def handle_call(:ensemble, _, ensemble) do
    {:reply, ensemble, ensemble}
  end

  def handle_call({:add, id, instrument}, _, ensemble) do
    ensemble =
      Map.put(
        ensemble,
        id,
        build_instrument_map(instrument, ensemble)
      )
      |> reindex!

    {:reply, Map.get(ensemble, id), ensemble}
  end

  def handle_cast({:remove, id}, ensemble) do
    ensemble =
      ensemble
      |> Map.delete(id)
      |> reindex!

    {:noreply, ensemble}
  end

  def handle_cast(:reset!, _) do
    {:noreply, %{}}
  end

  defp build_instrument_map(instrument, ensemble) do
    %{
      instrument: instrument,
      index: instrument_count(ensemble, instrument) + 1,
      label: instrument
    }
  end

  defp instrument_count(ensemble, instrument) do
    Enum.count(ensemble, fn {_, map} ->
      map[:instrument] == instrument
    end)
  end

  defp reindex!(ensemble) do
    ensemble =
      ensemble
      |> Enum.map(fn {_, m} -> m[:instrument] end)
      |> Enum.uniq()
      |> Enum.reduce(ensemble, fn inst, acc ->
        count = instrument_count(ensemble, inst)

        Enum.filter(acc, fn {_, m} -> m[:instrument] == inst end)
        |> Enum.reduce(acc, fn {id, inst_map}, inner_acc ->
          new_index = calculate_new_index(inst_map[:index], count)
          new_label = calculate_new_label(inst_map[:instrument], new_index, count)

          Map.put(inner_acc, id, %{inst_map | index: new_index, label: new_label})
        end)
      end)

    ensemble
  end

  defp calculate_new_index(current_index, count) do
    if current_index > count, do: current_index - 1, else: current_index
  end

  defp calculate_new_label(instrument, index, count) do
    if count == 1, do: instrument, else: Enum.join([instrument, index], " ")
  end
end
