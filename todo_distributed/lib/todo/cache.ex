defmodule Todo.Cache do
#  use GenServer

# def init(_) do
#     # Todo.Database.start_link("./persist/")
#     {:ok, nil}
# end

  # def handle_call({:server_process, todo_list_name}, _, state) do
  #   todo_server_pid = case Todo.Server.whereis(todo_list_name) do
  #     :undefined ->
  #       {:ok, pid} = Todo.ServerSupervisor.start_child(todo_list_name)
  #       pid
  #
  #     pid -> pid
  #   end
  #   {:reply, todo_server_pid, state}
  # end
  #
  # def start_link do
  #   IO.puts "Starting to-do cache."
  #   GenServer.start_link(__MODULE__, nil, name: :todo_cache)
  # end
  #
  def server_process(todo_list_name) do
    case Todo.Server.whereis(todo_list_name) do
      :undefined -> create_server(todo_list_name)
      #        GenServer.call(:todo_cache, {:server_process, todo_list_name})

      pid -> pid
    end
  end

  defp create_server(todo_list_name) do
    case Todo.ServerSupervisor.start_child(todo_list_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end

