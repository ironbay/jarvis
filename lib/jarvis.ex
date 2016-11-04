defmodule Jarvis do
	use Application
#
	# See http://elixir-lang.org/docs/stable/elixir/Application.html
	# for more information on OTP Applications
	def start(_type, _args) do
		import Supervisor.Spec, warn: false

		stores = [
			{Delta.Stores.Cassandra, {}}
		]
		plugins = []

		# Define workers and child supervisors to be supervised
		children = [
			# Starts a worker by calling: Bot.Worker.start_link(arg1, arg2, arg3)
			supervisor(Delta, [stores, plugins, Delta]),
			worker(Jarvis.Proxy, []),
			worker(Jarvis.Rest, []),
		]


		# See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
		# for other strategies and supported options
		opts = [strategy: :one_for_one, name: Jarvis]
		Supervisor.start_link(children, opts)
	end
end

defmodule Jarvis.Proxy do
	use GenServer

	def start_link do
		GenServer.start_link(__MODULE__, [])
	end

	def init(_) do
		{:ok, bot} = Bot.start_link(:jarvis)

		# Core
		Bot.enable_skill(bot, Bot.Skill.Regex, [])
		Bot.enable_skill(bot, Bot.Skill.Locale, [])
		Bot.enable_skill(bot, Bot.Skill.Controller, [])
		Bot.enable_skill(bot, Bot.Skill.User, [])
		Bot.enable_skill(bot, Bot.Skill.Link, [])

		# Fun
		Bot.enable_skill(bot, Bot.Skill.Joke, [])
		Bot.enable_skill(bot, Bot.Skill.Greeter, [])
		Bot.enable_skill(bot, Bot.Skill.Name, [])

		# Slack
		case System.get_env("SLACK_TOKENS") do
			nil -> :skip
			result ->
				result
				|> String.split(",")
				|> Enum.each(fn token -> Bot.enable_skill(bot, Bot.Skill.Slack, [token, ""]) end)
		end

		# Reddit
		Bot.enable_skill(bot, Jarvis.Reddit.Link, [])
		Bot.enable_skill(bot, Jarvis.Reddit.Joke, [])
		Bot.enable_skill(bot, Jarvis.Reddit.Poller, ["futurology"])

		# Link
		Bot.enable_skill(bot, Jarvis.Link, [])
		Bot.enable_skill(bot, Bot.Skill.Alchemy, ["67f1fe52543de6001b8d1cff4e60f2e0d3404e7b"])
		Bot.enable_skill(bot, Jarvis.Wolfram, ["99AK9Y-RQEX2UU3GT"])
		Bot.enable_skill(bot, Jarvis.Graph, [])
		Bot.enable_skill(bot, Jarvis.Media, [])

		# Torrent
		Bot.enable_skill(bot, Jarvis.Media.TL, [])
		Bot.enable_skill(bot, Jarvis.Media.Download, [])

		# Music
		Bot.enable_skill(bot, Jarvis.Music, [])

		Bot.enable_skill(bot, Jarvis.ContextIO.Register, [])

		# Video
		# Bot.enable_skill(bot, Jarvis.Media.Youtube, ["channel/UCWrmUNZB9-p6zgNhwNlEcyw"])
		# Bot.enable_skill(bot, Jarvis.Media.Youtube, ["user/taimur38"])

		Bot.enable_skill(bot, Bot.Skill.Giphy, [])
		{:ok, []}
	end
end
