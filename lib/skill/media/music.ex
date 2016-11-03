defmodule Jarvis.Music do
	require Logger
	use Bot.Skill

	def begin(bot, []) do
		Bot.cast(bot, "regex.add", {"^find song (?P<query>.+)", "music.search"})
		{:ok, Delta.start_session(Delta, "jarvis")}
	end

	def handle_cast_async({"graph", body = %{url: url, title: title}, context}, bot, session) do
		case Regex.scan(~r/(.+)(-|by)(.+)/, title) do
			[] -> :skip
			[[_, left, _, right]] ->
				"#{cleanse(left)} - #{cleanse(right)}"
				|> search
				|> List.first
				|> create
				|> broadcast(bot, context)
			_ ->
		end
	end

	def handle_cast_async({"music.search", body = %{query: query}, context}, bot, session) do
		query
		|> search
		|> List.first
		|> create
		|> broadcast(bot, context)
		:ok
	end

	def cleanse(title) do
		title = Regex.replace(~r/\(.*\)/, title, "")
		title = Regex.replace(~r/\(.*\)/, title, "")
		title = Regex.replace(~r/ft(.+)[-]*/, title, "")
		title = Regex.replace(~r/feat(.+)[-]*/, title, "")
		title = Regex.replace(~r/featuring(.+)[-]*$/, title, "")
		title = String.trim(title)
	end

	def search(query) do
		Logger.info("Searchin songlink for #{query}")
		"www.songl.ink/search?search=#{URI.encode(query)}"
		|> HTTPoison.get!
		|> Map.get(:body)
		|> Poison.decode!(as: %{})
	end

	def create(data) do
		json = Poison.encode!(data)
		"http://www.songl.ink/create"
		|> HTTPoison.post!(json, [
			{"Content-Type", "application/json"}
		])
		|> Map.get(:body)
		|> Poison.decode!(as: %{})
	end

	def broadcast(data, bot, context) do
		%{"share_link" => link} = data
		Bot.cast(bot, "bot.message", link, context)
	end

end
