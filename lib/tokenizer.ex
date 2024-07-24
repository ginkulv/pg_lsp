defmodule Tokenizer do
  defmodule Token do
    defstruct [:type, :value, :line, :left, :right] 

    @type t :: %Token{
      type: :entity | :keyword | :symbol,
      value: String.t(),
      line: integer(),
      left: integer(),
      right: integer(),
    }
  end

  def keywords() do
    ["SELECT", "FROM"]
  end

  @doc """
  This function takes code as input and converts it to a list of tokens.
  Token represents the first layer of parsing code.
  Some symbols, e.g. `*`, can have different meaning depending on the context.
  Tokens are supposed to read them irregardless of their meaning, so `*` is just a symbol,
  `select` is a word etc.
  """
  @spec tokenize(list(String.t()), integer(), integer()) :: list(Token.t())
  def tokenize(str, line \\ 0, position \\ 0)
  def tokenize([], _line, _position), do: []
  def tokenize(str, line, position) do
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
      {:err, head} ->
        IO.puts :stderr, "Couldn't parse an element: " <> head
        []
    end
  end

  @spec get_token(list(String.t()), integer(), integer()) :: tuple()
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
    |> String.upcase

    type = case value |> String.upcase |> String.contains?(keywords()) do
      true -> :keyword
      false -> :entity
    end

    %Token{type: type, value: value, line: line, left: position, right: position + String.length(value)}
  end

  defp get_token(str, line, position, :symbol) do
    %Token{type: :symbol, value: hd(str), line: line, left: position, right: position + 1}
  end
end
