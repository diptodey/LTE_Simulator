defmodule Controller.MixProject do
  use Mix.Project

  def project do
    [
      app: :controller,
      version: "0.1.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      #mod: {application, []},
      extra_applications: [:logger],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nwsim, path: "../nwsim" },
      {:users, path: "../users" },
    ]
  end
end
