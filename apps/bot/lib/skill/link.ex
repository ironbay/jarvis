defmodule Bot.Skill.Link do
	use Bot.Skill

	def begin(bot, args) do
		Bot.broadcast(bot, "regex.add", {"(?P<url>http[^\\s|\\|\\>]+)", "link"})
		{:ok, %{}}
	end

end
