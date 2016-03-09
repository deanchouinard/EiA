defmodule Todo.Database do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder,
      name: :database_server
      )
  end

  def store(key, data) do
    Todo.DatabaseWorker.store(getworker(state, key), {:store, key, data})
  end

  def get(key) do
    pid = getworker(state, key)
    Todo.DatabaseWorker.get(pid, key)
    #    GenServer.call(:database_server, {:get, key})
  end

  def init(db_folder) do
    acc = HashDict.new
    table = Enum.reduce([0,1,2], acc, fn(x, acc) ->
      {:ok, pid} = Todo.DatabaseWorker.start(db_folder)
      HashDict.put(acc, x, pid) end)
    IO.inspect(table)
    {:ok, table }
      #    File.mkdir_p(db_folder)
      #    {:ok,  db_folder}
  end

  defp getworker(table, key) do
    i = :erang.phash2(key, 3)
    HashDict.get(table, i)
  end

  def handle_cast({:store, key, data}, db_folder) do
    file_name(db_folder, key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

  def handle_call({:get, key}, _, db_folder) do
    data = case File.read(file_name(db_folder, key)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end
    
    {:reply,  data, db_folder}
  end

  defp file_name(db_folder, key), do: "#{db_folder}/#{key}"
end

