defmodule TodoList do
  use GenServer

  defstruct auto_id: 1, entries: HashDict.new

  def start do
    GenServer.start(TodoList, nil)
  end

  def put(pid, value) do
    GenServer.cast(pid, {:put, value})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def update(pid, key, u_fun) do
    GenServer.cast(pid, {:upd, key, u_fun})
  end

  def delete(pid, key) do
    GenServer.cast(pid, {:del, key})
  end

  def init(_) do
    {:ok, TodoList.new}
  end

  def handle_call({:get, key}, _, state) do
    {:reply, TodoList.entries(state, key), state}
  end
  
  def handle_cast({:put, value}, state) do
    {:noreply, TodoList.add_entry(state, value)}
  end

  def handle_cast({:upd, key, u_fun}, state) do
    {:noreply, TodoList.update_entry(state, key, u_fun)}
  end

  def handle_cast({:del, key}, state) do
    {:noreply, TodoList.delete_entry(state, key)}
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

IO.puts "Server_process_todo"

{:ok, pid}  = TodoList.start

TodoList.put(pid, %{date: {2013, 12, 19}, title: "Dentist"})
TodoList.put(pid, %{date: {2013, 12, 20}, title: "Shopping"})
TodoList.put(pid, %{date: {2013, 12, 19}, title: "Movies"})

TodoList.get(pid, {2013, 12, 19}) |> IO.inspect

IO.puts "\n*** Updating an entry"
TodoList.update(pid, 1, &Map.put(&1, :date, {2013, 12, 20}))

TodoList.get(pid, {2013, 12, 19}) |> IO.inspect

IO.puts "\n*** Delete entry"
TodoList.get(pid, {2013, 12, 20}) |> IO.inspect
TodoList.delete(pid, 1)
# IO.inspect(todo_list)
TodoList.get(pid, {2013, 12, 20}) |> IO.inspect
