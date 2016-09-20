defmodule Bot.Skill.Reddit.Joke do
	use Bot.Skill
	@base "https://www.reddit.com"

	def begin(bot, []) do
		Bot.broadcast(bot, "regex.add", {"tell me a joke$", "joke.search"})
		Bot.broadcast(bot, "regex.add", {"(how|why|what)", "joke.answer"})
		{:ok, %{}}
	end

	def on({"joke.search", _body, context}, bot, data) do
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
				Bot.broadcast(bot, "chat.response", question, context)
				Bot.wait(bot, context, ["joke.answer"])
				Bot.broadcast(bot, "chat.response", answer, context)
			true ->
				Bot.broadcast(bot, "chat.response", "#{question} #{answer}", context)
		end
		{:ok, data}
	end

end
