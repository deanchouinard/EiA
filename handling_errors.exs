try_helper = fn(fun) ->
  try do
    fun.()
    IO.puts "No error"
  catch type, value ->
    IO.puts "Error\n #{inspect type}\n #{inspect value}"
  end
end

try_helper.(fn -> raise("Something went wrong")end)

try_helper.(fn -> throw("Thrown value")end)
try_helper.(fn -> exit("I'm done")end)
result = try do
    throw("Thrown value")
  catch type, value -> {type, value}
  end

try do
  raise("something went wrong")
catch
  _,_ -> IO.puts "error caught"
after
  IO.puts "cleanup"
end
