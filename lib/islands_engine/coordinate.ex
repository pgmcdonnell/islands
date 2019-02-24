defmodule IslandsEngine.Coordinate do
  @moduledoc """
  Coordinates represent points on the game board
  """
  alias __MODULE__

  @enforce_keys [:row, :col]
  defstruct [:row, :col]

  @board_range 1..10

  @doc """
  Creates a new coordinate with validity checks.

  ## Examples
    iex> IslandsEngine.Coordinate.new(1,1)
    {:ok, %IslandsEngine.Coordinate{row: 1, col: 1}}

    iex> IslandsEngine.Coordinate.new(18,5)
    {:error, :invalid_coordinate}
  """
  def new(row, col) when row in(@board_range) and col in(@board_range) do
    {:ok, %Coordinate{row: row, col: col}}
  end

  def new(_row, _col), do: {:error, :invalid_coordinate}

end
