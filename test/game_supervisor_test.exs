defmodule GameSupervisorTest do
  use ExUnit.Case

  alias IslandsEngine.{Game, GameSupervisor}

  describe "supervisor manages game" do
    test "starts successfully" do
      {:ok, _game} = GameSupervisor.start_game("Patrick")
      via = Game.via_tuple("Patrick")
      process = GenServer.whereis(via)
      Game.add_player(via, "Katie")
      state_data = :sys.get_state(via)

      assert true == Process.alive?(process)
      assert :players_set == state_data.rules.state
    end

    test "stops sucessfully" do
      {:ok, _game} = GameSupervisor.start_game("Danaidh")
      via = Game.via_tuple("Danaidh")
      process = GenServer.whereis(via)
      GameSupervisor.stop_game("Danaidh")

      assert false == Process.alive?(process)
    end

    test "handles restarting game processes which crash" do
      {:ok, game} = GameSupervisor.start_game("Katie")
      via = Game.via_tuple("Katie")

      initial_process = GenServer.whereis(via)
      Process.exit(game, :kaboom)
      Process.sleep(2) #allow time for restart to happen, generous allowance
      restarted_process = GenServer.whereis(via)

      refute initial_process == restarted_process
      assert false == Process.alive?(initial_process)
      assert true == Process.alive?(restarted_process)
    end

  end

end
