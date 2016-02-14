Code.require_file("todo_crud.ex", nil)
import TodoList

todo_list = TodoList.new |>
  TodoList.add_entry(%{date: {2013, 12, 19}, title: "Dentist"})

TodoList.entries(todo_list, {2013, 12, 19})
