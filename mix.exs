defmodule Jarvis.Mixfile do
  use Mix.Project

  def project do
    [app: :jarvis,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :bot, :neo4j_sips, :sweet_xml, :exirc, :httpoison, :delta, :plug, :cowboy, :postgrex],
	mod: {Jarvis, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
		{:httpoison, "~> 0.8.0"},
		# {:bot, path: "~/dev/ironbay/bot"},
		{:oauther, "~> 1.0.1"},
		{:bot, git: "https://github.com/ironbay/bot.git"},
		{:sweet_xml, "~> 0.6.1"},
		{:exirc, "~> 0.11.0"},
		{:neo4j_sips, "~> 0.2"},
		# {:delta, github: "ironbay/delta-elixir"},
		{:delta, path: "~/dev/ironbay/delta-elixir", only: [:dev]},
		{:plug, "~> 1.0"},
		{:cowboy, "~> 1.0.3"},
        {:postgrex, "~> 1.0.0-rc.1"},
		{:credo, "~> 0.5", only: [:dev, :test]}
	]
  end
end
