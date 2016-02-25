defmodule DatabaseServer do
  def start do
    spawn(fn ->
      connection = :random.uniform(1000)
      loop(connection) end )
  end

  defp loop(connection) do

    receive do
      {:run_query, from_pid, query_def} ->
        query_result = run_query(connection, query_def)
        send(from_pid, {:query_result, query_result})
    end

    loop(connection)

  end

  def run_async(server_pid, query_def) do
    send(server_pid, {:run_query, self, query_def})
  end

  def get_result do
    receive do
      {:query_result, result} -> result
    after 5000 ->
      {:error, :timeout}
    end
  end

  defp run_query(connection, query_def) do
    :timer.sleep(2000)
    "Connection #{connection}: #{query_def} result"
  end
end

server_pid = DatabaseServer.start

DatabaseServer.run_async(server_pid, "query 1")

IO.puts DatabaseServer.get_result

DatabaseServer.run_async(server_pid, "query 2")

IO.puts DatabaseServer.get_result

# pool = 1..100 |> Enum.map(fn(_) -> DatabaseServer.start end)

#1..5 |> Enum.each(fn(query_def) ->
#  server_pid = Enum.at(pool, :random.uniform(100) - 1)
#  DatabaseServer.run_async(server_pid, query_def)
#end)

# 1..5 |> Enum.map(fn(_) -> DatabaseServer.get_result end)



