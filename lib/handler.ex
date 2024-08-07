defmodule Handler do
  def handle_request(nil), do: nil
  def handle_request(request) do
    method = request["method"]
    id = request["id"]
    params = request["params"]
    handle(method, id, params)
  end

  defp handle(method, id, params)
  defp handle("initialize", id, _params) do
    response = %{
      result: %{
        capabilities: %{
          textDocumentSync: %{openClose: true, change: 1},
          diagnosticProvider: %{identifier: "help", interFileDependencies: false, workspaceDiagnostics: false},
        },
        serverInfo: %{name: "pglsp", version: "0.1"}
      },
      jsonrpc: "2.0",
      id: id
    }
    {:ok, resp} = JSON.encode(response)
    content_length = String.length(resp)
    IO.write(:stderr, resp)

    IO.write("Content-Length: #{content_length}\r\n\r\n#{resp}")
  end

  defp handle("initialized", _id, _params) do
    IO.write :stderr, "pglsp was initialized successfully"
  end

  defp handle("shutdown", _id, _params) do
    IO.write :stderr, "shutting down test LSP"
    :todo
  end

  defp handle("textDocument/didOpen", _id, params) do
    doc = params["textDocument"]
    text = doc["text"]
    _version = doc["version"]
    _languageId = doc["languageId"]
    _uri = doc["uri"]
    IO.puts :stderr, text
  end

  defp handle("textDocument/didChange", _id, params) do
    doc = params["textDocument"]
    _version = doc["version"]
    uri = doc["uri"]
    changes = params["contentChanges"]
    changes
    |> Enum.each(fn c -> IO.puts(:stderr, c["text"]) end)

    token_request = fn token -> %{
            range: %{start: %{line: token.line, character: token.left}, end: %{line: token.line, character: token.right}},
            message: token.value,
    } end

    diagnostics = changes
      |> Enum.map(fn c -> Parser.parse(c["text"]) end)
      |> Enum.flat_map(fn tokens ->
        Enum.map(tokens, &token_request.(&1))
      end)
    response = %{
      method: "textDocument/publishDiagnostics",
      params: %{
        uri: uri,
        diagnostics: diagnostics
      },
      jsonrpc: "2.0",
    }
    {:ok, resp} = JSON.encode(response)
    content_length = String.length(resp)
    IO.write(:stderr, resp)

    IO.write("Content-Length: #{content_length}\r\n\r\n")
    IO.write(resp)
  end
end
