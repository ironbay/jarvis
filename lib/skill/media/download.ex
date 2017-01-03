defmodule Jarvis.Media.Download do
	use Bot.Skill
	@wait 1000 * 60
	@key "c7afa073572a4ee09f8c"
	@tv "/media/content/union/tv"
	@downloaded "/media/torrents/downloaded"
	@cookies "__cfduid=dd4e194047843c4d6a501c8927af3f85e1445145199; __utma=194598568.1862899498.1445145199.1454834546.1454879669.128; _ga=GA1.2.1862899498.1445145199; member_id=53563; pass_hash=ef5be2fa3121fe9947bbbf247bddbc99; session_id=f73f16f6fa47c606253ac227fc8d8a59; itemMarking_forums_items=eJxLtDK0qs60MjaxsLC0zrQyNDE3MbI0NgRyagFiwwbb; tluid=522483; tlpass=52e939c0ed7adbd2304b1b898867c8a5a2e6d56f; PHPSESSID=grq60nchbpp84jh5otcdq403a4; lastBrowse1=1475432959; lastBrowse2=1475450576"

	def begin(bot, args) do
		Bot.cast(bot, "regex.add", {"^download (?P<query>.+)", "torrent.search"})
		Bot.cast(bot, "regex.add", {"^(?P<number>\\d+)$", "chat.number"})
		{:ok, %{}}
	end

	def handle_cast_async({"torrent.upload", %{name: name, category: "TV :: Episodes HD", id: id}, _context}, bot, data) do
		lower =
			name
			|> String.downcase
			|> String.replace(" ", ".")
		case File.ls!(@tv)
		|> Stream.filter(&String.contains?(lower, &1))
		|> Enum.take(1) do
			[] -> :skip
			_ ->
				:timer.sleep(@wait)
				Bot.call(bot, "torrent.download", %{id: id, name: name})
		end
		:ok
	end

	def handle_cast_async({"torrent.search", %{query: query}, context}, bot, data) do
		options = "https://classic.torrentleech.org/torrents/browse/index/query/#{query}/categories/10%2C11%2C13%2C14%2C36%2C37%2C41%2C43%2C32/orderby/leechers/order/desc"
		|> HTTPoison.get!(%{}, hackney: [cookie: [@cookies]])
		|> Map.get(:body)
		|> Floki.find("#torrenttable tbody tr")
		|> Stream.map(&parse_row(&1))
		|> Stream.with_index
		|> Stream.take(3)
		|> Enum.to_list

		case Enum.count(options) do
			0 ->
				Bot.cast(bot, "bot.message", "No results found :(", context)
			_ ->
				message =
					options
					|> Stream.map(fn {item, index} -> format(index, item) end)
					|> Enum.join("\n")
				Bot.cast(bot, "bot.message", "Which one?", context)
				Bot.cast(bot, "bot.message", message, context)

				{_, %{number: number}, _} = Bot.wait(bot, context, ["chat.number"])
				{item, _} = Enum.at(options, number)
				Bot.call(bot, "torrent.download", item)
				Bot.cast(bot, "bot.message", "Downloading #{item.name}", context)
		end
		:ok
	end

	def handle_call({"torrent.download", %{id: id, name: name}, _context}, bot, data) do
		body =
			"https://www.torrentleech.org/rss/download/#{id}/#{@key}/#{name}"
			|> HTTPoison.get!
			|> Map.get(:body)
		File.write!("#{@downloaded}/#{name}.torrent", body)
		:ok
	end

	defp parse_row(data) do
		%{
			name:
				data
				|> Floki.find(".title")
				|> Floki.text,
			id:
				data
				|> Floki.attribute("id")
				|> List.first,
			seeders:
				data
				|> Floki.find(".seeders")
				|> Floki.text,
			size:
				data
				|> Floki.find("td")
				|> Enum.at(4)
				|> Floki.text,
		}
	end

	defp format(index, item) do
		"#{index}. #{item.name} (#{item.size}) (#{item.seeders} seeders)"
	end

end
