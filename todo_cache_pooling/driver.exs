{:ok, cache} = Todo.Cache.start

Todo.Cache.server_process(cache, "Bob's list")

Todo.Cache.server_process(cache, "Bob's list")
alice_list = Todo.Cache.server_process(cache, "Alice's list")
charlie_list = Todo.Cache.server_process(cache, "Charlie's list")

bobs_list = Todo.Cache.server_process(cache, "Bob's list")

Todo.Server.add_entry(bobs_list, %{date: {2013, 12, 19}, title: "Dentist"})
Todo.Server.add_entry(bobs_list, %{date: {2013, 12, 20}, title: "Movies"})
IO.puts "bobs_list"
IO.inspect Todo.Server.entries(bobs_list, {2013, 12, 19})

Todo.Server.add_entry(alice_list, %{date: {2013, 12, 20}, title: "Movies"})
Todo.Server.add_entry(alice_list, %{date: {2013, 12, 20}, title: "Movies"})
Todo.Server.add_entry(alice_list, %{date: {2013, 12, 19}, title: "Dentist"})
IO.puts "alice_list"
Todo.Cache.server_process(cache, "Alice's list") |>
  Todo.Server.entries({2013, 12, 19}) |> IO.inspect

Todo.Server.add_entry(charlie_list, %{date: {2013, 12, 20}, title: "Movies"})
Todo.Server.add_entry(charlie_list, %{date: {2013, 12, 20}, title: "Movies"})
Todo.Server.add_entry(charlie_list, %{date: {2013, 12, 19}, title: "Dentist"})
IO.puts "charlie_list"
Todo.Cache.server_process(cache, "Charlie's list") |>
  Todo.Server.entries({2013, 12, 19}) |> IO.inspect


  #IO.puts "verify running processes"
  #{:ok, cache} = Todo.Cache.start

  #IO.puts length(:erlang.processes)

  #1..100_000 |>
  #Enum.each(fn(index) -> 
  # Todo.Cache.server_process(cache, "to-do list #{index}")
  #end)

  #IO.puts length(:erlang.processes)


