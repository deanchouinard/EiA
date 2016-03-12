{:ok, cache} = Todo.Cache.start
bobs_list = Todo.Cache.server_process(cache, "bobs_list")
Todo.Server.add_entry(bobs_list, %{date: {2013, 12, 19}, title: "Dentist"})

