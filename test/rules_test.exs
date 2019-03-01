defmodule RulesTest do
  use ExUnit.Case
  doctest IslandsEngine.Rules

  alias IslandsEngine.Rules

  describe "rules follow the rules" do
    test "game starts out as expected" do
      expected = %Rules{state: :initialized, player1: :islands_not_set, player2: :islands_not_set}
      assert expected == Rules.new()
    end

    test "when we add a second player we transition to :players_set" do
      rules = Rules.new()
      assert {:ok, %Rules{state: :players_set}} = Rules.check(rules, :add_player)
    end

    test "a player can position islands before they set them" do
      rules = Rules.new() |> Map.put(:state, :players_set)
      assert {:ok, rules} = Rules.check(rules, {:position_islands, :player1})
    end

    test "a player cannot position islands after they set them" do
      rules =
        Rules.new()
        |> Map.put(:state, :players_set)
        |> Map.put(:player1, :islands_set)
      assert :error = Rules.check(rules, {:position_islands, :player1})
    end

    test "when one player sets their islands, the other player still has the chance to do the same" do
      rules = Rules.new() |> Map .put(:state, :players_set)

      {:ok, %Rules{player1: :islands_set} = new_rules} = Rules.check(rules, {:set_islands, :player1})
      assert {:ok, _rules} = Rules.check(new_rules, {:position_islands, :player2})
    end

    test "once both players set their islands the rules move to player 1's turn" do
      rules = Rules.new() |> Map.put(:state, :players_set)

      {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
      {:ok, %Rules{player2: :islands_set} = new_rules} = Rules.check(rules, {:set_islands, :player2})
      expected_rules = %Rules{state: :player1_turn, player1: :islands_set, player2: :islands_set}
      assert ^expected_rules = new_rules
    end
  end

  test "after player one guesses, it's player two's turn" do
    rules = Rules.new() |> Map.put(:state, :player1_turn)
    assert {:ok, %Rules{state: :player2_turn}} = Rules.check(rules, {:guess_coordinate, :player1})
  end

  test "after player two guesses, it's player one's turn" do
    rules = Rules.new() |> Map.put(:state, :player2_turn)
    assert {:ok, %Rules{state: :player1_turn}} = Rules.check(rules, {:guess_coordinate, :player2})
  end

  test "the game is over when player 1 wins" do
    rules = Rules.new() |> Map.put(:state, :player1_turn)
    assert {:ok, %Rules{state: :game_over}} = Rules.check(rules, {:win_check, :win})
  end

  test "the game is over when player 2 wins" do
    rules = Rules.new() |> Map.put(:state, :player2_turn)
    assert {:ok, %Rules{state: :game_over}} = Rules.check(rules, {:win_check, :win})
  end
end
