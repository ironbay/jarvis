defmodule Jarvis.Media.Download do
	use Bot.Skill
	@tv "/media/content/union/tv"
	@key "c7afa073572a4ee09f8c"
	@path "/media/torrents/downloaded"

	def begin(bot, args) do
		{:ok, %{}}
	end

	def on({"torrent.upload", %{name: name, category: "TV :: Episodes HD", id: id}, _context}, bot, data) do
		lower = String.downcase(name)
		case File.ls!(@tv)
		|> Stream.filter(&String.contains?(lower, &1))
		|> Enum.take(1) do
			[] -> :skip
			_ ->
				body =
					"https://www.torrentleech.org/rss/download/#{id}/#{@key}/#{name}"
					|> HTTPoison.get!
					|> Map.get(:body)
				File.write!("#{@path}/#{name}.torrent", body)
		end
		:ok
	end
end
