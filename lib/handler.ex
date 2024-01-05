defmodule Handler do
  def handle_request(request) do
    id = request["id"]
    method = request["method"]
    params = request["params"]
    handle(id, method, params)
  end

  defp handle(id, method, params \\ %{})
  defp handle(id, "initialize", _params) do
    response = %{
      :result => %{capabilities: %{}, serverInfo: %{name: "pglsp", version: "0.1"}},
      :jsonrpc => "2.0",
      :id => id
    }
    {:ok, resp} = JSON.encode(response)
    content_length = String.length(resp)
    IO.write(:stderr, resp)

    IO.write("Content-Length: #{content_length}\r\n\r\n")
    IO.write(resp)
  end

  defp handle(nil, "initialized", _params) do
    IO.write :stderr, "pglsp was initialized successfully"
  end

  defp handle(_id, "shutdown", _params) do
    IO.write :stderr, "shutting down test LSP"
    System.stop(0)
  end
end
