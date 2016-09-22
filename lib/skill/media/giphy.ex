defmodule Jarvis.Media.Giphy do
	use Bot.Skill
	@base "http://api.giphy.com/"

	def begin(bot, args) do
		Bot.cast(bot, "regex.add", {"^gif (?P<query>.+)", "giphy.search"})
		Bot.cast(bot, "locale.add", {"bot.gif", "<%= url %>"})
		{:ok, %{}}
	end

	def on({"giphy.search", %{query: query}, context}, bot, data) do
		url = HTTPoison.get!("#{@base}v1/gifs/search?q=#{URI.encode(query)}&api_key=dc6zaTOxFJmzC")
		|> Map.get(:body)
		|> Poison.decode!(as: %{})
		|> Kernel.get_in(["data"])
		|> Enum.at(0)
		|> Map.get("url")
		Bot.cast(bot, "bot.gif", %{
			url: url,
		}, context)
		{:ok, data}
	end
end
