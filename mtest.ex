defmodule MapTest do
  lst = [1, 2, 3, 4]

  def mkmap(list) do
    pmap = Map.new
    mk_map(list, pmap)
  end

  def mk_map([], pmap), do: pmap
  def mk_map([head | tail], pmap) do
      pmap = Map.put(pmap, to_string(head), head)
      IO.inspect(pmap)
      mk_map(tail, pmap)
  end

end

IO.inspect(MapTest.mkmap([1, 2, 3, 4]))
IO.inspect(MapTest.mkmap([[1, 2], [3, 4]]))

