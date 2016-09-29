defmodule Jarvis.Reddit.Joke do
	use Bot.Skill
	@base "https://www.reddit.com"

	def begin(bot, []) do
		Bot.cast(bot, "regex.add", {"tell me a joke$", "joke.search"})
		Bot.cast(bot, "regex.add", {"^(who|what|when|where|why|how)$", "joke.answer"})
		{:ok, %{}}
	end

	def handle_cast({"joke.search", _body, context}, bot, data) do
		{question, answer} = HTTPoison.get!("#{@base}/r/dadjokes.json")
		|> Map.get(:body)
		|> Poison.decode!(as: %{})
		|> Kernel.get_in(["data", "children"])
		|> Stream.map(&Map.get(&1, "data"))
		|> Stream.map(fn(item) ->
			{Map.get(item, "title"), Map.get(item, "selftext")}
		end)
		|> Enum.random
		cond do
			String.ends_with?(question, "?") ->
				Bot.cast(bot, "bot.message", question, context)
				Bot.wait(bot, context, ["joke.answer"])
				Bot.cast(bot, "bot.message", answer, context)
			true ->
				Bot.cast(bot, "bot.message", "#{question} #{answer}", context)
		end
		:ok
	end

end
