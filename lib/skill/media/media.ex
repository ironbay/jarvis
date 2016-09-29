defmodule Jarvis.Media do
	use Bot.Skill

	def begin(bot, args) do
		Bot.cast(bot, "regex.add", {"show me a (?P<type>.+)", "media.search"})
		# Bot.cast(bot, "locale.add", {"graph", "This <%= type %> is lit"})
		Bot.cast(bot, "locale.add", {"media.result", "<%= url %>"})
		{:ok, %{
			"video" => %{},
			"music.song" => %{},
		}}
	end

	def handle_cast({"graph", body = %{url: url, type: type}, context}, bot, data) do
		{:ok, Kernel.put_in(data, [type, url], body)}
	end

	def handle_cast({"media.search", body = %{type: type}, context}, bot, data) do
		{_, result} = data
		|> Map.get(translate(type))
		|> Enum.random
		Bot.cast(bot, "media.result", result, context)
		:ok
	end

	defp translate(type) do
		case type do
			"song" -> "music.song"
			_ -> type
		end
	end
end
