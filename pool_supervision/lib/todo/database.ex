defmodule Todo.Database do
  use GenServer
  @pool_size 3

  def start_link(db_folder) do
    IO.puts "Starting database server."
    Todo.PoolSupervisor.start_link(db_folder, @pool_size)
    #   GenServer.start_link(__MODULE__, db_folder,
    # name: :database_server
    # )
  end

  def store(key, data) do
  #    GenServer.cast(:database_server, {:store, key, data})
    key
    |> choose_worker
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
  #    GenServer.call(:database_server, {:get, key})
    key
    |> choose_worker
    |> Todo.DatabaseWorker.get(key)
  end

  #def init(db_folder) do
    #acc = HashDict.new
    #table = Enum.reduce([0,1,2], acc, fn(x, acc) ->
      #  {:ok, pid} = Todo.DatabaseWorker.start_link(db_folder)
      #HashDict.put(acc, x, pid) end)
      #    IO.inspect(table)
      #{:ok, table }
      #    File.mkdir_p(db_folder)
      #    {:ok,  db_folder}
      # end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end

  #  defp getworker(table, key) do
    # i = :erlang.phash2(key, 3)
    # HashDict.get(table, i)
    #end

    #  def handle_cast({:store, key, data}, state) do
      # Todo.DatabaseWorker.store(getworker(state, key), key, data)
    #    file_name(db_folder, key)
    #|> File.write!(:erlang.term_to_binary(data))

    # {:noreply, state}
    # end

    #def handle_call({:get, key}, _, state) do
      # pid = getworker(state, key)
      #data = Todo.DatabaseWorker.get(pid, key)
    #    data = case File.read(file_name(db_folder, key)) do
      # {:ok, contents} -> :erlang.binary_to_term(contents)
      # _ -> nil
      #end
    
      #{:reply,  data, state}
      #end

      #defp file_name(db_folder, key), do: "#{db_folder}/#{key}"
end

