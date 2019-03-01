defmodule IslandTest do
  use ExUnit.Case
  doctest IslandsEngine.Island

  alias IslandsEngine.{Coordinate, Island}

  @top_left_coords %Coordinate{row: 1, col: 1}
  @bottom_right_coord %Coordinate{row: 10, col: 10}

  describe "creating islands" do
    test "can add island with valid coordinates" do
      assert {:ok, %Island{} = island} = Island.new(:atoll, @top_left_coords)
    end
    test "cannot add island when it goes off the board" do
      assert {:error, :invalid_coordinate} = Island.new(:atoll, @bottom_right_coord)
    end
  end

  describe "checking for overlaps" do
    test "identifies overlapping islands" do
      {:ok, existing_island} = Island.new(:atoll, @top_left_coords)
      {:ok, new_island} = Island.new(:dot, @top_left_coords)
      assert true == Island.overlaps?(existing_island, new_island)
    end
    test "does not identify non-overlapping islands" do
      {:ok, existing_island} = Island.new(:atoll, @top_left_coords)
      {:ok, new_island} = Island.new(:dot, @bottom_right_coord)
      assert false == Island.overlaps?(existing_island, new_island)
    end
  end

  describe "Guessing coordinates" do
    test "returns hit when we guess correctly" do
      {:ok, island} = Island.new(:atoll, @top_left_coords)
      {:ok, guess} = Coordinate.new(1,2)
      assert {:hit, %Island{} = island} = Island.guess(island, guess)
    end
    test "returns miss when we guess incorrectly" do
      {:ok, island} = Island.new(:atoll, @top_left_coords)
      {:ok, guess} = Coordinate.new(2,1)
      assert :miss = Island.guess(island, guess)
    end
  end

  describe "checking if an island is forested" do
    test "returns true when the island is forested" do
      {:ok, new_island} = Island.new(:dot, @top_left_coords)
      {:ok, accurate_guess} = Coordinate.new(1,1)
      {:hit, hit_island} = Island.guess(new_island, accurate_guess)
      assert true == Island.forested?(hit_island)
    end
    test "returns false when the island is not forested" do
      {:ok, island} = Island.new(:atoll, @top_left_coords)
      assert false == Island.forested?(island)
    end
  end
end
