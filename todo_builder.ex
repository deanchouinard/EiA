defmodule TodoList do
  defstruct auto_id: 1, entries: HashDict.new


  def new(entries \\ []) do
    Enum.reduce(entries, %TodoList{},
    fn(entry, todo_list_acc) ->
      add_entry(todo_list_acc, entry)
    end
    )
  end

  def add_entry(
    %TodoList{entries: entries, auto_id: auto_id} = todo_list,
    entry) do
      entry = Map.put(entry, :id, auto_id)
      new_entries = HashDict.put(entries, auto_id, entry)

      %TodoList{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end
end

entries = [
  %{date: {2013, 12, 29}, title: "Dentist"},
  %{date: {2013, 12, 20}, title: "Shopping"},
  %{date: {2013, 12, 29}, title: "Movies"}
]

todo_list = TodoList.new(entries)
IO.inspect(todo_list)

