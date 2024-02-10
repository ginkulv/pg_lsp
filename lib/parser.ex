defmodule Parser do
  @spec parse(String.t()) :: list(Token.t())
  def parse(str) do
    String.graphemes(str)
    |> Tokenizer.tokenize
  end
end
