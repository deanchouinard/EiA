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
    |> Enum.map(&String.replace(&1, "\n", ""))
    |> Enum.map(&(String.split(&1, ",")))
    |> IO.inspect
    |> process_list2
    |> convert_date
    |> Enum.map(&(List.to_tuple(&1)))
    |> date_to_tuple
    |> convert_to_list_of_maps
    # |> Enum.map(&(List.to_tuple(&1)))
    # |> Enum.map(&(String.lstrip(&1)))
    #    |> Enum.each
    #    |> String.split(&1, "/") |> IO.inspect
  end

  def convert_to_list_of_maps(list) do
    IO.inspect(list)
   for {{date}, loc} <- list, into: Map.new, do: { date,  loc} 
    #    for x <- list, into: Map.new, do: { x } 
    #   |> Enum.map(&Enum.into(&1, Map.new))
  end

  def date_to_tuple([]), do: []
  def date_to_tuple([{date, loc} | tail]), do: [{List.to_tuple(date), loc }
      | date_to_tuple(tail)]
  def convert_date([]), do: []
  def convert_date([[[year, month, day], loc] | tail]), do:
  [[[String.to_integer(year), String.to_integer(month), String.to_integer(day)], loc ] | convert_date(tail)]

  def process_list2([]), do: []
  def process_list2([head = [xdate, xloc]  | tail]), do: [ head =
    [String.split(xdate,"/"),
      String.lstrip(xloc)] | process_list2(tail)]
  def process_list([]), do: []
  def process_list([head | tail]), do: [pr_line(head) | process_list(tail)]

  def pr_line([]), do: []
  def pr_line([head | tail]), do: [pr_string(head) | pr_line(tail)]

  def pr_string(string) do
    String.split(String.lstrip(string), "/")
  end
end

todo_list = TodoList.CsvImporter.import("todos.csv")
IO.puts "\n*** Imported data"
IO.inspect(todo_list)



#    |> Enum.filter(fn(line) -> true end) |> IO.inspect
