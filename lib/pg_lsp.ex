defmodule PgLsp do
  import Handler

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
    {:ok, request} = JSON.decode(data)
    IO.write :stderr, "Request: #{data}"
    handle_request(request)
  end

end
