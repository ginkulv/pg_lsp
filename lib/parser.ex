defmodule Parser do
  @spec  parse(String.t()) :: String.t()
  def parse(str) do
    str
    |> tokenize
  end

  @spec tokenize(String.t()) :: String.t()
  defp tokenize(str) do
    ""
  end
end
