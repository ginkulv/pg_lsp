defmodule Parser do
  defmodule Token do
    defstruct [:type, :value, :line, :left, :right] 

    @type t :: %Token{
      type: nil | :word | :column | :relation,
      value: String.t()
    }
  end

  @spec parse(String.t()) :: list(Token.t())
  def parse(str) do
    String.graphemes(str)
    |> tokenize
  end

  defp tokenize([]), do: []
  defp tokenize(str, line \\ 0, position \\ 0) do
    IO.puts :stderr, str
    token = get_token(str, line, position)
    case token do
      {:value, token} ->
        new_position = token.right
        new_str = Enum.drop(str, new_position - position)
        [token | tokenize(new_str, token.line, new_position)]
      {:space, nil} ->
        tokenize(Enum.drop(str, 1), line, position + 1)
      {:newline, nil} ->
        tokenize(Enum.drop(str, 1), line + 1, position)
      {:eof, nil} ->
        []
      {:err, head} ->
        IO.puts :stderr, "Couldn't parse an element: " <> head
        []
    end
  end

  @spec get_token(list(String.t()), integer(), integer()) :: tuple()
  defp get_token([], _, _), do: {:eof, nil}
  defp get_token(str, line, position) do
    head = hd(str)
    cond do
      String.match?(head, ~r/^[a-z]$/i) -> {:value, get_token(str, line, position, :word)}
      String.contains?(head, [".", ",", "*", "+", "-", "/", ";"]) -> {:value, get_token(str, line, position, :symbol)}
      String.contains?(head, ["\n", "\r\n"]) -> {:newline, nil}
      head == " " -> {:space, nil}
      true -> {:err, head}
    end
  end

  @spec get_token(list(String.t()), integer(), integer(), :word | :symbol) :: Token.t()
  defp get_token(str, line, position, type)
  defp get_token(str, line, position, :word) do
    value = str
    |> Enum.take_while(&String.match?(&1, ~r/^[a-z]$/i))
    |> Enum.join

    %Token{type: :word, value: value, line: line, left: position, right: position + String.length(value)}
  end

  defp get_token(str, line, position, :symbol) do
    %Token{type: :symbol, value: hd(str), line: line, left: position, right: position + 1}
  end
end
