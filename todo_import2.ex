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

defmodule TodoList.CsvImporter do

  def import(data_file) do
    File.stream!(data_file) 
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&(String.split(&1, ",")))
    |> Stream.map(&proc_line(&1))
    |> Stream.map(&conv_date(&1))
    |> Enum.map(&mk_tup(&1))
    #    |> Stream.map(&mk_tup(&1))
    #|> Enum.map(fn(x) -> x end)
    |> IO.inspect
  end

  def mk_tup([date, title] = _line) do
    %{date: List.to_tuple(date), title: title}
  end

  def conv_date([[year, month, day], title] = _line) do
    [[String.to_integer(year), String.to_integer(month),
        String.to_integer(day)], title]
  end

  def proc_line([date, title] = _line) do
    [String.split(date,"/"), String.lstrip(title)]
  end

end

todo_list = TodoList.CsvImporter.import("todos.csv")
IO.puts "\n*** Imported data"
IO.inspect(todo_list)
todo_list = TodoList.new(todo_list)
IO.inspect(todo_list)

