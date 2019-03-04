defmodule GameSupervisorTest do
  use ExUnit.Case

  alias IslandsEngine.{Game, GameSupervisor}

  setup do
    {:ok, game} = GameSupervisor.start_game("Patrick")

    on_exit fn ->
      GameSupervisor.stop_game("Patrick")
    end

    {:ok, %{game: game}}
  end

  describe "supervisor manages game" do
    test "starts successfully", %{game: _game} do
      via = Game.via_tuple("Patrick")
      process = GenServer.whereis(via)
      Game.add_player(via, "Katie")
      state_data = :sys.get_state(via)

      assert true == Process.alive?(process)
      assert :players_set == state_data.rules.state
    end

    test "stops sucessfully", %{game: _game} do
      via = Game.via_tuple("Patrick")
      process = GenServer.whereis(via)
      GameSupervisor.stop_game("Patrick")

      assert false == Process.alive?(process)
    end

    test "handles restarting game processes which crash", %{game: game} do
      via = Game.via_tuple("Patrick")

      initial_process = GenServer.whereis(via)
      Process.exit(game, :kaboom)
      Process.sleep(2) #allow time for restart to happen, generous allowance
      restarted_process = GenServer.whereis(via)

      refute initial_process == restarted_process
      assert false == Process.alive?(initial_process)
      assert true == Process.alive?(restarted_process)
    end
  end

  describe "adding a player" do
    test "to an initialized game works", %{game: game} do
      assert :ok == Game.add_player(game, "Wilma")
    end

    test "fails when we already have two players", %{game: game} do
      Game.add_player(game, "Wilma")
      assert :error == Game.add_player(game, "Dino")
    end
  end

  describe "positioning an island" do
    test "works when the island and coordinates are valid", %{game: game} do
      assert :ok == Game.add_player(game, "Wilma")
      assert :ok == Game.position_island(game, :player1, :atoll, 1, 1)
    end

    test "fails when the island coordinates are wrong", %{game: game} do
      assert :ok == Game.add_player(game, "Wilma")
      assert {:error, :invalid_coordinate} == Game.position_island(game, :player1, :atoll, 10, 10)
    end

    test "fails when the island is unknown type", %{game: game} do
      assert :ok == Game.add_player(game, "Wilma")
      assert {:error, :invalid_island_type} == Game.position_island(game, :player1, :wrong, 5, 5)
    end

    test "fails when the game is not in set_islands state", %{game: game} do
      assert :error == Game.position_island(game, :player1, :atoll, 5, 5)
    end
  end

  describe "setting islands" do
    test "is denied before we add a second player", %{game: game} do
      assert :error == Game.set_islands(game, :player1)
    end
    test "is denied before positioning all islands", %{game: game} do
      Game.add_player(game, "Wilma")
      Game.position_island(game, :player1, :atoll, 1, 1)
      assert {:error, :not_all_islands_positioned} = Game.set_islands(game, :player1)
    end

    test "works after positioning all islands", %{game: game} do
      Game.add_player(game, "Wilma")
      position_all_islands_for_player(game, :player1)
      assert {:ok, board} = Game.set_islands(game, :player1)
    end
  end

  describe "guessing coordinates" do
    test "works for valid coordinate", %{game: game} do
      Game.add_player(game, "Wilma")
      position_all_islands_for_player(game, :player1)
      position_all_islands_for_player(game, :player2)
      Game.set_islands(game, :player1)
      Game.set_islands(game, :player2)
      assert {:miss, :none, :no_win} = Game.guess_coordinate(game, :player1, 9, 9)
    end

    test "fails if it isn't players turn", %{game: game} do
      Game.add_player(game, "Wilma")
      position_all_islands_for_player(game, :player1)
      position_all_islands_for_player(game, :player2)
      Game.set_islands(game, :player1)
      Game.set_islands(game, :player2)
      assert :error = Game.guess_coordinate(game, :player2, 9, 9)
    end

    test "fails if coordinates are invalid", %{game: game} do
      Game.add_player(game, "Wilma")
      position_all_islands_for_player(game, :player1)
      position_all_islands_for_player(game, :player2)
      Game.set_islands(game, :player1)
      Game.set_islands(game, :player2)
      assert {:error, :invalid_coordinate} = Game.guess_coordinate(game, :player1, 12, 19)
    end
  end

  defp position_all_islands_for_player(game, player) do
    Game.position_island(game, player, :atoll, 1, 1)
    Game.position_island(game, player, :dot, 5, 2)
    Game.position_island(game, player, :square, 5, 3)
    Game.position_island(game, player, :s_shape, 8, 1)
    Game.position_island(game, player, :l_shape, 1, 5)
  end
end
