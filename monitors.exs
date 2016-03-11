target_pid = spawn(fn ->
  :timer.sleep(1000)
end)

Process.monitor(target_pid)

receive do
  msg -> IO.inspect msg
end
