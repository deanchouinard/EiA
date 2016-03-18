Todo.Supervisor.start_link
for _ <- 1..6 do
  Process.whereis(:todo_cache) |> Process.exit(:kill)
  :timer.sleep(200)
end

