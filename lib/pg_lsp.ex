defmodule PgLsp do
  def hello do
    :world
  end

  def main(_args \\ []) do
    IO.puts(:stderr,  "started test LSP")
    serve()
    IO.puts(:stderr,  "shutting down test LSP")
  end


  def serve do
    read_message()
    serve()
  end

  defp read_message do
    line = IO.read(:line)
    IO.puts(:stderr, line)
    content_length = line
    |> String.split(" ")
    |> List.last
    |> String.trim
    |> Integer.parse

    length = case content_length do
      {length, _ } -> length
      :error -> nil
    end

    read_body(length)
  end

  defp read_body(nil), do: nil
  defp read_body(length) do
    IO.read(1)
    data = IO.read(length)
    {:ok, json} = JSON.decode(data)
    IO.write :stderr, "Request: #{data}"
    id = json["id"]
    method = json["method"]

    handle(id, method)
  end

  defp handle(id, "initialize") do
    response = %{
      :result => %{capabilities: %{}, serverInfo: %{name: "pglsp", version: "0.1"}},
      # :result => %{capabilities: %{hoverProvider: true}},
      :jsonrpc => "2.0",
      :id => id
    }
    {:ok, resp} = JSON.encode(response)
    content_length = String.length(resp)
    IO.write(:stderr, resp)

    IO.write("Content-Length: #{content_length}\r\n\r\n")
    IO.write(resp)
  end

  defp handle(_id, "initialized") do
    IO.write :stderr, "pglsp was initialized successfully"
  end
end
