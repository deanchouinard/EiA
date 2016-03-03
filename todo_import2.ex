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
    |> Enum.map(fn(x) -> x end)
    |> IO.inspect
    
    #    |> process_list2
    #|> IO.inspect
    #|> convert_date
    #|> IO.inspect
    #|> Enum.map(&(List.to_tuple(&1)))
    #|> IO.inspect
    #|> date_to_tuple
    #|> IO.inspect
    #|> makmap


    # |> convert_to_list_of_maps
    # |> Enum.map(&(List.to_tuple(&1)))
    # |> Enum.map(&(String.lstrip(&1)))
    #    |> Enum.each
    #    |> String.split(&1, "/") |> IO.inspect
  end

  def conv_date(line) do
    [[year, month, day], title] = line
    line = [[String.to_integer(year), String.to_integer(month),
        String.to_integer(day)], title]
  end

  def proc_line(line) do
    line = List.update_at(line, 0, &String.split(&1,"/"))
    line = List.update_at(line, 1, &String.lstrip(&1))
    IO.inspect(line)
    line
  end

  def makmap([]), do: []
  def makmap([head | tail]) do 
    tm = %{}
    lst = Tuple.to_list(head)
    tm = Map.put_new(tm, :date, List.first(lst))
    tm = Map.put_new(tm, :title, List.last(lst))
    #    tm = Map.put_new(tm, :loc, head[1])
    head = tm
    IO.inspect(head)
    [ head | makmap(tail)]
  end
  
  def makmap2([]), do: []
  def makmap2([head | tail]) do 
    [  Tuple.insert_at(head, 0, "date:" ) | makmap2(tail)]
  end
  def mkmap(list) do
    pmap = Map.new
    mk_map(list, pmap)
  end

  def mk_map([], pmap), do: pmap
  def mk_map([head | tail], pmap) do
      pmap = Map.put(pmap, head, head)
      #    IO.inspect(pmap)
      mk_map(tail, pmap)
  end

  def convert_to_list_of_maps(list) do
    imp_map = Map.new()
    Enum.each(list,
    fn(item, imp_map) ->
      date = List.first(item)
      loc = List.last(item)
      #      IO.inspect(date)
      imp_map = Map.put(imp_map, :date , loc)
      IO.inspect(imp_map)
    end)
    imp_map
      
    #   IO.inspect(list)
    # for {{date}, loc} <- list, into: Map.new, do: { date,  loc} 
    #    for x <- list, into: Map.new, do: { x } 
    #   |> Enum.map(&Enum.into(&1, Map.new))
  end

  def date_to_tuple([]), do: []
  def date_to_tuple([{date, loc} | tail]), do: [{List.to_tuple(date), loc}
      | date_to_tuple(tail)]
  
  def convert_date([]), do: []
  def convert_date([[[year, month, day], loc] | tail]), do:
  [[[String.to_integer(year), String.to_integer(month), String.to_integer(day)], loc ] | convert_date(tail)]

  def process_list2([]), do: []
  def process_list2([head = [xdate, xloc]  | tail]), do: [ head =
    [String.split(xdate,"/"),
      String.lstrip(xloc)] | process_list2(tail)]

  # def process_list([]), do: []
  # def process_list([head | tail]), do: [pr_line(head) | process_list(tail)]

  # def pr_line([]), do: []
  # def pr_line([head | tail]), do: [pr_string(head) | pr_line(tail)]

  # def pr_string(string) do
    # String.split(String.lstrip(string), "/")
    #end
end

todo_list = TodoList.CsvImporter.import("todos.csv")
IO.puts "\n*** Imported data"
IO.inspect(todo_list)
todo_list = TodoList.new(todo_list)
IO.inspect(todo_list)



#    |> Enum.filter(fn(line) -> true end) |> IO.inspect
