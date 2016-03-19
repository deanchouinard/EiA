defmodule Todo.ProcessRegistry do
  use GenServer
  
  import Kernel, except: [send: 2]

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end
  
  def send(key, message) do
    case whereis_name(key) do
      :undefined -> {:badarg, {key, message}}
    #      nil -> {:badarg, {key, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  def init(_) do
    :ets.new(:ets_process_registry, [:set, :named_table, :protected])
    {:ok, nil}
  end

  defp read_cached(key) do
    case :ets.lookup(:ets_process_registry, key) do
      [{^key, cached}] -> cached
      _ -> nil
    end
  end

  def register_name(key, pid) do
    IO.puts "register name"
    read_cached(key) ||
    GenServer.call(:process_registry, {:register_name, key, pid})
  end

  def handle_call({:register_name, key, pid},_,_) do
    IO.inspect(key)
    IO.puts "handle call register"
    case read_cached(key) do
      nil -> cache_response(key, pid)
      _ -> {:reply, :no, nil}
    end 
  end

  defp cache_response(key, pid) do
    Process.monitor(pid)
    :ets.insert(:ets_process_registry, {key, pid})
    {:reply, :yes, nil}
  end

  def unregister_name(key) do
    GenServer.call(:process_registry, {:unregister_name, key})
    #    send(key, {:DOWN, nil, :process, key})
  end
  
  def handle_call({:unregister_name, key}, _) do
    :ets.match_delete(:ets_process_registry, {key, :_})
    {:reply, key}
  end

  def show_registry() do
    IO.inspect(:ets.tab2list(:ets_process_registry))
  end

  def handle_info({:DOWN, _, :process, pid, _}, _) do
    {:noreply, deregister_pid(pid)}
  end

  def handle_info(_, _), do: {:noreply, :_}
  #  def handle_info(_, state), do: {:noreply, state}

  defp deregister_pid( pid) do
    :ets.match_delete(:ets_process_registry, {:_, pid})
  end

  def whereis_name(key) do
  #    GenServer.call(:process_registry, {:whereis_name, key})
  IO.inspect(key)
    case :ets.lookup(:ets_process_registry, key) do
      [{^key, cached}] -> cached
      #    _ -> nil
      _ -> :undefined
    end
  end
end
