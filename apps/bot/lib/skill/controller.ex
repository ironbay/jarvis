defmodule Bot.Skill.Controller do
	use Bot.Skill

	def begin(bot, args) do
		Bot.broadcast(bot, "regex.add", {"^enable skill (?P<input>.+) (?P<args>.+)", "skill.enable"})
		{:ok, %{}}
	end

	def on({"skill.enable", %{input: input, args: args}, context}, bot, data) do
		splits = String.split(args, " ")
		module = String.to_existing_atom("Elixir.#{input}")
		Bot.enable_skill(bot, module, splits)
		Bot.broadcast(bot, "chat.response", "Enabled #{module} with #{inspect(splits)}", context)
		{:ok, data}
	end
end
