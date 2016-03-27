{:ok, cache} = Todo.Cache.start
bobs_list = Todo.Cache.server_process(cache, "bobs_list")
Todo.Server.entries(bobs_list, {2013, 12, 19}) |> IO.inspect

