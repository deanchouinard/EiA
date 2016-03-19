defmodule Todo.ProcessRegistry do
  use GenServer
  
  import Kernel, except: [send: 2]

  def send(key, message) do
    case whereis_name(key) do
    #      :undefined -> {:badarg, {key, message}}
      nil -> {:badarg, {key, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  def init(_) do
  #    {:ok, HashDict.new}
    :ets.new(:ets_process_registry, [:set, :named_table, :protected])
    {:ok, nil}
  end

  #  def handle_call({:register_name, key, pid}, _, process_registry) do
    # case HashDict.get(process_registry, key) do
  # nil ->
    #      Process.monitor(pid)
    #   {:reply, :yes, HashDict.put(process_registry, key, pid)}
  # _ ->
    #     {:reply, :no, process_registry}
    # end
    #end
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
    #    {:reply, :yes, nil}
    # _ ->
      #   {:reply, :no}
  end

  #  def handle_call({:whereis_name, key}, _, process_registry) do
  #    IO.inspect(process_registry)
  # IO.inspect(key)
  # {:reply, HashDict.get(process_registry, key, :undefined),
    #   process_registry}
  # end

  #  def handle_call({:unregister_name, key}, _, process_registry) do
    # {:reply, key, HashDict.delete(process_registry, key)}
    #end

  def handle_call({:unregister_name, key}, _) do
    :ets.match_delete(:ets_process_registry, {key, :_})
    {:reply, key}
  end

  def handle_cast({:show_registry}, process_registry) do
    IO.inspect(process_registry)
    {:noreply, process_registry}
  end

  def show_registry() do
    IO.inspect(:ets.tab2list(:ets_process_registry))

    # GenServer.cast(:process_registry, {:show_registry})
  end

  def handle_info({:DOWN, _, :process, pid, _}) do
    {:noreply, deregister_pid(pid)}
  end

  #  def handle_info({:DOWN, _, :process, pid, _}, process_registry) do
  #    {:noreply, deregister_pid(new_registry, pid)}
  #  IO.puts "info"
  # {:noreply, deregister_pid(process_registry, pid)}
  # end

  def handle_info(_), do: {:noreply}
  #  def handle_info(_, state), do: {:noreply, state}

  defp deregister_pid( pid) do
    :ets.match_delete(:ets_process_registry, {:_, pid})
  end

  # defp deregister_pid(process_registry, pid) do
  #    {HashDict.delete(new_registry, pid)}
  #    {Enum.filter(new_registry, fn({key, value} = x) -> value != pid end)}
  # Enum.reduce(process_registry, process_registry,
  # fn ({registered_alias, registered_process}, registry_acc)
 #   when registered_process == pid ->
   #      HashDict.delete(registry_acc, registered_alias)

   #    (_, registry_acc) -> registry_acc

   #end
   #)
   #end
 
  def whereis_name(key) do
  #    GenServer.call(:process_registry, {:whereis_name, key})
  IO.inspect(key)
    case :ets.lookup(:ets_process_registry, key) do
      [{^key, cached}] -> cached
      #    _ -> nil
      _ -> :undefined
    end
  end

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end


  def unregister_name(key) do
    GenServer.call(:process_registry, {:unregister_name, key})
    #    send(key, {:DOWN, nil, :process, key})
  end
end
