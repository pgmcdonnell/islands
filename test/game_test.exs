defmodule GameTest do
  use ExUnit.Case, async: true
  doctest IslandsEngine.Game

  alias IslandsEngine.Game

  setup do
    {:ok, game} = Game.start_link("Fred")
    {:ok, %{game: game}}
  end
end
