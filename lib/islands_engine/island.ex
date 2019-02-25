defmodule IslandsEngine.Island do
  @moduledoc """
  Islands are a series of coordinates on a game board.
  """

  alias IslandsEngine.{Coordinate, Island}

  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct [:coordinates, :hit_coordinates]


  @doc """
  Creates a new island, based on the type of island and the top-left coordinate.

  ## Examples
    iex> IslandsEngine.Island.new(:l_shape, %IslandsEngine.Coordinate{col: 6, row: 4})
    {:ok, %IslandsEngine.Island{
            coordinates: [%IslandsEngine.Coordinate{col: 6, row: 4},%IslandsEngine.Coordinate{col: 6, row: 5},%IslandsEngine.Coordinate{col: 6, row: 6},%IslandsEngine.Coordinate{col: 7, row: 6}] |> Enum.into(MapSet.new()),
            hit_coordinates: MapSet.new()}}
  """
  def new(type, %Coordinate{} = upper_left) do
    with [_|_] = offsets <- offsets(type),
          %MapSet{} = coordinates <- add_coordinates(offsets, upper_left)
    do
      {:ok, %Island{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    else
      error -> error
    end
  end

  defp offsets(:square), do: [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  defp offsets(:atol), do: [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]
  defp offsets(:dot), do: [{0, 0}]
  defp offsets(:l_shape), do: [{0, 0}, {1, 0}, {2, 0}, {2, 1}]
  defp offsets(:s_shape), do: [{0, 1}, {0, 2}, {1, 0}, {1, 1}]
  defp offsets(_), do: {:error, :invalid_island_type}

  defp add_coordinates(offsets, upper_left) do
    offsets
    |> Enum.reduce_while(MapSet.new(),
                          fn offset, acc ->
                            add_coordinate(acc, upper_left, offset)
                          end)
  end

  defp add_coordinate(coordinates, %Coordinate{row: row, col: col}, {row_offset, col_offset}) do
    case Coordinate.new(row + row_offset, col + col_offset) do
      {:ok, coordinate} -> {:cont, MapSet.put(coordinates, coordinate)}
      {:error, :invalid_coordinate} -> {:halt, {:error, :invalid_coordinate}}
    end
  end

end