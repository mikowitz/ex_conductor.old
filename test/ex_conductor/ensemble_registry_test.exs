defmodule ExConductor.EnsembleRegistryTest do
  use ExUnit.Case, async: true

  alias ExConductor.EnsembleRegistry

  setup do
    EnsembleRegistry.reset!()
    {:ok, []}
  end

  test "registry begins empty" do
    assert EnsembleRegistry.ensemble() == %{}
  end

  test "can add an ensemble member" do
    EnsembleRegistry.add(1, "violin")

    assert EnsembleRegistry.ensemble() ==
             %{
               1 => %{
                 instrument: "violin",
                 index: 1,
                 label: "violin"
               }
             }
  end

  test "adding a second of the same instrument" do
    EnsembleRegistry.add(1, "violin")
    EnsembleRegistry.add(2, "violin")

    assert EnsembleRegistry.ensemble() ==
             %{
               1 => %{
                 instrument: "violin",
                 index: 1,
                 label: "violin 1"
               },
               2 => %{
                 instrument: "violin",
                 index: 2,
                 label: "violin 2"
               }
             }
  end

  test "removing the first of the same instrument" do
    EnsembleRegistry.add(1, "violin")
    EnsembleRegistry.add(2, "violin")

    EnsembleRegistry.remove(1)

    assert EnsembleRegistry.ensemble() ==
             %{
               2 => %{
                 instrument: "violin",
                 index: 1,
                 label: "violin"
               }
             }
  end

  test "index is not tied to id" do
    %{instrument: "violin", index: 1, label: "violin"} = EnsembleRegistry.add(1, "violin")
    %{instrument: "violin", index: 2} = EnsembleRegistry.add(2, "violin")

    EnsembleRegistry.remove(1)
    %{instrument: "violin", index: 2, label: "violin 2"} = EnsembleRegistry.add(1, "violin")

    assert EnsembleRegistry.ensemble() ==
             %{
               1 => %{
                 instrument: "violin",
                 index: 2,
                 label: "violin 2"
               },
               2 => %{
                 instrument: "violin",
                 index: 1,
                 label: "violin 1"
               }
             }
  end

  describe "for_user/1" do
    test "returns nil when the user has not joined" do
      refute EnsembleRegistry.for_user(1)
    end

    test "returns instrument data when the user has joined" do
      inst_data = EnsembleRegistry.add(1, "cello")

      assert EnsembleRegistry.for_user(1) == inst_data
    end
  end
end
