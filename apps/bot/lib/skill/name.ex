defmodule Bot.Skill.Name do
	use Bot.Skill

	def begin(bot, args) do
		Bot.broadcast(bot, "regex.add", {"^call me (?P<name>.+)$", "name.change"})
		Bot.broadcast(bot, "regex.add", {"^what is my name", "name.query"})
		Bot.broadcast(bot, "locale.add", {"name.set", "Great I'll call you <%= name %>"})
		Bot.broadcast(bot, "locale.add", {"name.response", "Your name is <%= name %>"})
		# TODO: Load this from database
		{:ok, %{
			name: "unknown"
		}}
	end

	def on({"name.change", %{name: name}, context}, bot, data) do
		Bot.broadcast(bot, "name.set", %{name: name}, context)
		{:ok, %{
			name: name
		}}
	end

	def on({"name.query", _body, context}, bot, data = %{name: name} ) do
		Bot.broadcast(bot, "name.response", data, context)
		{:ok, data}
	end

end
