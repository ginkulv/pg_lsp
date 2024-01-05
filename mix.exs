defmodule PgLsp.MixProject do
  use Mix.Project

  def project do
    [
      app: :pg_lsp,
      version: "0.1.0",
      elixir: "~> 1.14",
      escript: escript(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def escript do
    [
      main_module: PgLsp,
      name: "pg_lsp.escript"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end


  defp deps do
    [
      {:json, "~> 1.4"}
    ]
  end
end
