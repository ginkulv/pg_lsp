defmodule Parser do
  @spec parse(String.t()) :: list(Token.t())
  def parse(str) do
    str
    |> String.graphemes
    |> Tokenizer.tokenize
    |> build_ast
  end

  defp build_ast(tokens) do
  end
end
