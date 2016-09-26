defmodule Jarvis.Media.Video do
	use Bot.Skill

	def begin(bot, args) do
		Bot.cast(bot, "regex.add", {"play a video", "video.search"})
		Bot.cast(bot, "locale.add", {"video.result", "<%= url %>"})
		{:ok, MapSet.new()}
	end

	def handle_cast({"video", body, context}, bot, _data) do
		{:modify, &MapSet.put(&1, body)}
	end

	def handle_cast({"video.search", body, context}, bot, data) do
		Bot.cast(bot, "video.result", Enum.random(data), context)
		:ok
	end
end
