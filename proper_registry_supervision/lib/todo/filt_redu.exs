# testing why my filter did not work
# - of course, does not output a HashDict
#

process_registry = Enum.into [one: 1, two: 2], HashDict.new
pid = 2

ef = Enum.filter(process_registry, fn({key, value} = x) -> value != pid end)

er = Enum.reduce(process_registry, process_registry,
    fn ({registered_alias, registered_process}, registry_acc)
      when registered_process == pid ->
        HashDict.delete(registry_acc, registered_alias)

        (_, registry_acc) -> registry_acc

    end
    )

IO.puts "filter"
IO.inspect(ef)
IO.puts "reduce"
IO.inspect(er)

