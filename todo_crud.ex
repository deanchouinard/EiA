defmodule TodoList do
  defstruct auto_id: 1, entries: HashDict.new

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

todo_list = TodoList.new |>
  TodoList.add_entry(%{date: {2013, 12, 19}, title: "Dentist"}) |>
  TodoList.add_entry(%{date: {2013, 12, 20}, title: "Shopping"}) |>
  TodoList.add_entry(%{date: {2013, 12, 19}, title: "Movies"})

TodoList.entries(todo_list, {2013, 12, 19}) |> IO.inspect

IO.puts "\n*** Updating an entry"
todo_list = TodoList.update_entry(todo_list, 1, 
  &Map.put(&1, :date, {2013, 12, 20}))

TodoList.entries(todo_list, {2013, 12, 19}) |> IO.inspect

IO.puts "\n*** Whole todo_list"
IO.inspect(todo_list)

IO.puts "\n*** Delete entry"
todo_list = TodoList.delete_entry(todo_list, 1)
IO.inspect(todo_list)
