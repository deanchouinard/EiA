defmodule PageCache do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :page_cache)

  end

  def init(_) do
    {:ok, HashDict.new}
  end

  def cached(key, cont_fun) do
    GenServer.call(:page_cache, {:cached, key, cont_fun})
  end

  def handle_call({:cached, key, cont_fun}, _, cache_data) do
    case HashDict.fetch(cache_data, key) do
      {:ok, data} ->
      #        IO.puts "cache hit"
        {:reply, data, cache_data}
      :error ->
        data = cont_fun.()
        {:reply, data, HashDict.put(cache_data, key, data)}
    end
  end
end
