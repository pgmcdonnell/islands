defmodule IslandsEngine.BoardTest do
  use ExUnit.Case

  doctest IslandsEngine.Board

  alias IslandsEngine.{Board, Coordinate, Island}

  describe "a board is just a map" do
    test "making a new board returns a map" do
      assert %{} == Board.new()
    end
  end

  describe "positioning an island" do
    test "is accepted where there's no overlap" do
      {:ok, island} = Island.new(:atoll, %Coordinate{row: 1, col: 1})
      assert %{atoll: ^island} = Board.position_island(%{}, :atoll, island)
    end

    test "is rejected where there is overlap" do
      {:ok, atoll} = Island.new(:atoll, %Coordinate{row: 1, col: 1})
      board = Board.position_island(%{}, :atoll, atoll)
      {:ok, dot} = Island.new(:dot, %Coordinate{row: 2, col: 2})
      assert {:error, :overlapping_island} = Board.position_island(board, :dot, dot)
    end
  end

  describe "checking all islands are positioned" do
    test "returns true where islands are positioned" do
      assert true == populated_board() |> Board.all_islands_positioned?()
    end

    test "returns false where islands not all positioned" do
      incomplete_board = populated_board() |> Map.delete(:atoll)
      assert false == Board.all_islands_positioned?(incomplete_board)
    end
  end

  describe "guessing a coordinate" do
    test "returns hit when accurate" do
      response = populated_board() |> Board.guess(%Coordinate{row: 1, col: 1})
      assert {:hit, :none, :no_win, board} = response

      hits = MapSet.new() |> MapSet.put(%Coordinate{col: 1, row: 1})
      assert hits == board.atoll.hit_coordinates
    end

    test "returns miss and when missed guess" do
      response = populated_board() |> Board.guess(%Coordinate{row: 10, col: 10})
      assert {:miss, :none, :no_win, board} = response
    end

    test "returned board is unchanged when guess is a miss" do
      response = populated_board() |> Board.guess(%Coordinate{row: 10, col: 10})
      {:miss, :none, :no_win, board} = response
      assert board == populated_board()
    end

    test "returns hit and island key when hit and forested" do
      response = populated_board() |> Board.guess(%Coordinate{row: 5, col: 2})
      assert {:hit, :dot, :no_win, board} = response
    end

    test "returns hit, island key, and win when hit and last island forested" do
      response = populated_board()
                  |> guess_all_except_dot
                  |> Board.guess(%Coordinate{row: 5, col: 2})
      assert {:hit, :dot, :win, board} = response
    end
  end

  defp populated_board do
    {:ok, atoll} = Island.new(:atoll, %Coordinate{row: 1, col: 1})
    {:ok, dot} = Island.new(:dot, %Coordinate{row: 5, col: 2})
    {:ok, square} = Island.new(:square, %Coordinate{row: 5, col: 3})
    {:ok, s_shape} = Island.new(:s_shape, %Coordinate{row: 8, col: 1})
    {:ok, l_shape} = Island.new(:l_shape, %Coordinate{row: 1, col: 5})

    %{}
    |> Board.position_island(:atoll, atoll)
    |> Board.position_island(:dot, dot)
    |> Board.position_island(:square, square)
    |> Board.position_island(:s_shape, s_shape)
    |> Board.position_island(:l_shape, l_shape)
  end

  defp guess_all_except_dot(board) do
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 1, col: 1})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 3, col: 1})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 1, col: 2})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 2, col: 2})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 3, col: 2})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 1, col: 5})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 2, col: 5})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 3, col: 5})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 3, col: 6})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 5, col: 3})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 5, col: 4})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 6, col: 3})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 6, col: 4})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 9, col: 1})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 9, col: 2})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 8, col: 2})
    {_, _, _, board} = Board.guess(board, %Coordinate{row: 8, col: 3})
    board
  end
end
