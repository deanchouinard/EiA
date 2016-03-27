Todo.Supervisor.start_link

bobs_list = Todo.Cache.server_process("Bob's List")
Todo.Server.entries(bobs_list, {2013, 12, 19})

IO.puts "Processes: #{length(:erlang.processes)}"

Process.whereis(:todo_cache) |> Process.exit(:kill)
:timer.sleep(500)
bobs_list = Todo.Cache.server_process("Bob's List")
IO.puts "Processes: #{length(:erlang.processes)}"

