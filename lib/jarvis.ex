defmodule Jarvis do
	use Application
#
	# See http://elixir-lang.org/docs/stable/elixir/Application.html
	# for more information on OTP Applications
	def start(_type, _args) do
		import Supervisor.Spec, warn: false

		# Define workers and child supervisors to be supervised
		children = [
			# Starts a worker by calling: Bot.Worker.start_link(arg1, arg2, arg3)
			# worker(Bot, ["jarvis"]),
		]

		{:ok, bot} = Bot.start_link("jarvis")
		Bot.enable_skill(bot, Bot.Skill.Regex, [])
		Bot.enable_skill(bot, Bot.Skill.Controller, [])
		Bot.enable_skill(bot, Bot.Skill.Locale, [])
		Bot.enable_skill(bot, Bot.Skill.Link, [])


		Bot.enable_skill(bot, Bot.Skill.Joke, [])
		Bot.enable_skill(bot, Bot.Skill.Greeter, [])
		Bot.enable_skill(bot, Bot.Skill.Name, [])

		Bot.enable_skill(bot, Bot.Skill.Slack, ["xoxb-41877287558-cGirzU5NfvqvswVrtZlUhBu8", ""])
		Bot.enable_skill(bot, Bot.Skill.Slack, ["xoxb-31798286241-HxuRQtrAPBwmKYx7oK6DEr51", "C07FCH70A"])
		Bot.enable_skill(bot, Bot.Skill.Slack, ["xoxb-78827137218-d6p8XDm72geFq4ne4SBloDkl", ""])

		Bot.enable_skill(bot, Jarvis.Reddit.Link, [])
		Bot.enable_skill(bot, Jarvis.Reddit.Joke, [])
		Bot.enable_skill(bot, Jarvis.Reddit.Poller, ["futurology"])

		Bot.enable_skill(bot, Bot.Skill.Alchemy, ["67f1fe52543de6001b8d1cff4e60f2e0d3404e7b"])
		Bot.enable_skill(bot, Jarvis.Wolfram, ["99AK9Y-RQEX2UU3GT"])
		Bot.enable_skill(bot, Jarvis.Graph, [])

		Bot.enable_skill(bot, Jarvis.Media.TL, [])
		Bot.enable_skill(bot, Bot.Skill.Giphy, [])
		# See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
		# for other strategies and supported options
		opts = [strategy: :one_for_one, name: Jarvis]
		Supervisor.start_link(children, opts)
	end
end