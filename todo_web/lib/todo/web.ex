defmodule Todo.Web do
  use Plug.Router

  plug :match
  plug :dispatch

  def start_server do
    case Application.get_env(:todo, :port) do
      nil -> raise("Todo port not specified!")
      port -> Plug.Adapters.Cowboy.http(__MODULE__, nil, port: port)
    end
  end

  get "/entries" do
    conn
    |> Plug.Conn.fetch_params
    |> fetch_entries
    |> respond
  end

  def fetch_entries(conn) do
    Plug.Conn.assign(
      conn,
      :response,
      entries(conn.params["list"], parse_date(conn.params["date"]))
      )
  end

  defp entries(list_name, date) do
    list_name
    |> Todo.Cache.server_process
    |> Todo.Server.entries(date)
    |> format_entries
  end

  defp format_entries(entries) do
    for entry <- entries do
      {y,m,d} = entry.date
      "#{y}-#{m}-#{d}   #{entry.title}"
    end
    |> Enum.join("\n")
  end

  post "/add_entry" do
    conn
    |> Plug.Conn.fetch_params
    |> add_entry
    |> respond
  end

  defp add_entry(conn) do
    conn.params["list"]
    |> Todo.Cache.server_process
    |> Todo.Server.add_entry(
      %{date: parse_date(conn.params["date"]),
        title: conn.params["title"]} )

    Plug.Conn.assign(conn, :response, "OK")
  end

  defp respond(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, conn.assigns[:response])
  end

  defp parse_date(
    # Using pattern matching to extract parts from YYYYMMDD string
    << year::binary-size(4), month::binary-size(2), day::binary-size(2) >>
   ) do
     {String.to_integer(year), String.to_integer(month), String.to_integer(day)}
  end
end
