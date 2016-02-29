defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
  end

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} = callback_module.handle_call(
          request,
          current_state
        )

        send(caller, {:response, response})

        loop(callback_module, new_state)

      {:cast, request} ->
        new_state = callback_module.handle_cast(
          request, current_state)

        loop(callback_module, new_state)
    end
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self})

    receive do
      {:response, response} ->
        response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end
end

defmodule KeyValueStore do
  def start do
    ServerProcess.start(KeyValueStore)
  end

  def put(pid, key, value) do
    ServerProcess.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  def init do
    HashDict.new
  end

  def handle_cast({:put, key, value}, state) do
    HashDict.put(state, key, value)
  end

  def handle_call({:put, key, value}, state) do
    {:ok, HashDict.put(state, key, value)}
  end

  def handle_call({:get, key}, state) do
    {HashDict.get(state, key), state}
  end
end

defmodule TodoServer do

  def start do
    spawn(fn -> loop(TodoList.new) end)
  end

  defp loop(todo_list) do
    new_todo_list = receive do
      message ->
        process_message(todo_list, message)
    end

    loop(new_todo_list)
  end


  def add_entry(todo_server, new_entry) do
    send(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, self, date})

    receive do
      {:todo_entries, entries} -> entries
    after 5000 ->
      {:error, :timeout}
    end
  end

  def update_entry(todo_server, entry_id, updater_fun) do
    send(todo_server, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(todo_server, entry_id) do
    send(todo_server, {:delete_entry, entry_id})
  end
  
  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end

  defp process_message(todo_list, {:update_entry, entry_id, updater_fun}) do
    TodoList.update_entry(todo_list, entry_id, updater_fun)
  end

  defp process_message(todo_list, {:delete_entry, entry_id}) do
    TodoList.delete_entry(todo_list, entry_id)
  end

end

defmodule TodoList do

  defstruct auto_id: 1, entries: HashDict.new

  def start do
    ServerProcess.start(TodoList)
  end

  def put(pid, value) do
    ServerProcess.cast(pid, {:put, value})
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  def init do
    TodoList.new
  end

  def handle_cast({:put, value}, state) do
    TodoList.add_entry(state, value)
  end

  def handle_call({:get, key}, state) do
    {TodoList.entries(state, key), state}
  end
  
  def new, do: %TodoList{}

  def add_entry(
    %TodoList{entries: entries, auto_id: auto_id} = todo_list,
    entry) do
      entry = Map.put(entry, :id, auto_id)
      new_entries = HashDict.put(entries, auto_id, entry)

      %TodoList{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end

  def entries(%TodoList{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) ->
      entry.date == date
    end)
    |> Enum.map(fn({_, entry}) ->
      entry
    end)
  end

  def update_entry(%TodoList{entries: entries} = todo_list,
    entry_id,
    updater_fun) do
    #      IO.inspect(entries[1])
      case entries[entry_id] do
        nil -> todo_list

        old_entry ->
          new_entry = updater_fun.(old_entry)
          new_entries = HashDict.put(entries, new_entry.id, new_entry)
          %TodoList{todo_list | entries: new_entries}
      end
    end

  def delete_entry(%TodoList{entries: entries} = todo_list,
    entry_id) do
    #      IO.inspect(entries[1])
      case entries[entry_id] do
        nil -> todo_list

        old_entry ->
          new_entries = HashDict.delete(entries, entry_id)
          %TodoList{todo_list | entries: new_entries}
      end
    end
end

todo_server = TodoServer.start

TodoServer.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Dentist"})
TodoServer.add_entry(todo_server, %{date: {2013, 12, 20}, title: "Shopping"})
  TodoServer.add_entry(todo_server, %{date: {2013, 12, 19}, title: "Movies"})

TodoServer.entries(todo_server, {2013, 12, 19}) |> IO.inspect

IO.puts "\n*** Updating an entry"
TodoServer.update_entry(todo_server, 1, &Map.put(&1, :date, {2013, 12, 20}))

TodoServer.entries(todo_server, {2013, 12, 19}) |> IO.inspect

#IO.puts "\n*** Whole todo_list"
# IO.inspect(todo_server)

IO.puts "\n*** Delete entry"
TodoServer.entries(todo_server, {2013, 12, 20}) |> IO.inspect
TodoServer.delete_entry(todo_server, 1)
# IO.inspect(todo_list)
TodoServer.entries(todo_server, {2013, 12, 20}) |> IO.inspect


pid = ServerProcess.start(KeyValueStore)
ServerProcess.call(pid, {:put, :some_key, :some_value})
ServerProcess.call(pid, {:get, :some_key})

#IO.puts "Using interface function calls"
pid = KeyValueStore.start
KeyValueStore.put(pid, :akey, :avalue)
KeyValueStore.get(pid, :akey)

IO.puts "Server_process_todo"

pid  = TodoList.start

TodoList.put(pid, %{date: {2013, 12, 19}, title: "Dentist"})
TodoList.put(pid, %{date: {2013, 12, 20}, title: "Shopping"})
TodoList.put(pid, %{date: {2013, 12, 19}, title: "Movies"})

TodoList.get(pid, {2013, 12, 19}) |> IO.inspect

