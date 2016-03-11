spawn(fn ->
  spawn_link(fn ->
    :timer.sleep(1000)
    IO.puts "process 2 finished"
  end)
  raise("someting wrong")
end)

spawn(fn ->
  Process.flag(:trap_exit, true)

  spawn_link(fn -> raise("someting wrong2")end)

  receive do
    msg -> IO.inspect(msg)
  end
end)
