employees = ["Alice", "Bob", "John"]

employees |>
Stream.with_index |>
Enum.each(fn({employee, index}) ->
  IO.puts "#{index + 1}. #{employee}" end)

[9, -1, "foo", 25, 49]  |>
Stream.filter(&(is_number(&1) and &1 > 0))  |>
Stream.map(&{&1, :math.sqrt(&1)})  |>
Stream.with_index  |>
Enum.each(fn({{input, result}, index}) -> 
IO.puts "#{index + 1}. sqrt(#{input}) = #{result}" end)

defmodule TestStreams do

  def large_lines!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.filter(&(String.length(&1) > 60))
    |> IO.puts
  end

  def lines_length!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&{&1, (String.length(&1))})
    |> Stream.with_index
    |> Enum.each(fn({{input, llen}, index}) ->
        IO.puts "#{index + 1}. #{llen} #{input}"
    end)
  end

  def longest_line_length!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.reduce( 0, &longest_line/2)
    |> IO.puts

  end

  defp longest_line(line, acc) do
    len = String.length(line)
    if len > acc, do: len, else: acc
  end
  #  defp longest_line(_, acc), do: acc

  def print_longest_line!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.reduce( {0," "}, &p_longest_line/2)
    |> p_lline

  end

  defp p_lline(tp), do: IO.puts elem(tp, 1)

  defp p_longest_line(line,{ acc, ll}) do
    len = String.length(line)
    #  IO.puts len
    if len > acc do
      acc = len
      ll = line
      #else
      #acc = acc
      #ll = ll
    end
    {acc, ll}
  end

  def words_per_line!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.reduce( 0, &p_words_line/2)
    |> IO.puts

  end

  defp p_words_line(line, acc) do
    words = length(String.split(line))
    IO.puts words
    acc = acc + words
  end


end


IO.puts "\n--- Large Lines; lines over 60 chars ---\n"
TestStreams.large_lines!("lines.txt")

IO.puts "\n--- Line Lengths; print line lengths ---\n"
TestStreams.lines_length!("lines.txt")

IO.puts "\n--- Longest Line length ---\n"
TestStreams.longest_line_length!("lines.txt")

IO.puts "\n--- Print Longest Line ---\n"
TestStreams.print_longest_line!("lines.txt")

IO.puts "\n--- Words Per Line ---\n"
TestStreams.words_per_line!("lines.txt")

