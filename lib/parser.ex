defmodule Parser do
  import Tokenizer.Token

  defp column_names() do
    ["column"]
  end

  defp from do
    %{table_name: 
      %{semicolon: default_grammar()}
    }
  end

  defp select do 
    %{column_name: %{
        from: from(),
        terminable: true
      }
    }
  end

  def default_grammar do
    %{select: select()}
  end

  def parse(str) do
    str
    |> String.graphemes
    |> Tokenizer.tokenize
    |> build_ast(default_grammar(), :nil)
  end


  @spec build_ast(list(Tokenizer.Token.t()), any(), atom()) :: list(Tokenizer.Token.t())
  defp build_ast(tokens, grammar, ctx) do
    token = tokens |> hd

    {ctx, grammar} = case token do
      %Tokenizer.Token{type: :keyword, value: "SELECT"} -> {:select, grammar[:select]}
      %Tokenizer.Token{type: :keyword, value: "FROM"} -> {:from, grammar[:from]}
      %Tokenizer.Token{type: :entity, value: _value} ->
        cond do
          ctx == :select -> grammar[:column_name]
          ctx == :from -> grammar[:table_name]
        end
      %{} -> nil
    end

    case grammar do
      nil -> [token]
      _ -> [token | build_ast(Enum.drop(tokens, 1), grammar, ctx)]
    end
  end
end
