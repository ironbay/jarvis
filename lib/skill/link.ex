defmodule Jarvis.Link do
	use Bot.Skill

	def begin(bot, []) do
		Bot.cast(bot, "regex.add", {"link history", "link.history"})
		Bot.cast(bot, "regex.add", {"^my links$", "link.mine"})
		Bot.cast(bot, "regex.add", {"^what do I like$", "link.analysis"})
		Bot.cast(bot, "regex.add", {"links about (?<tag>.+) from here", "link.search.channel"})
		{:ok, {}}
	end

	def handle_cast_async({"link.direct", %{url: url}, %{sender: sender, type: type, channel: channel}}, bot, _data) do
		Delta.add_fact(sender, "share:url", url)
		Delta.add_fact(channel, "contains:url", url)
		:ok
	end

	def handle_cast_async({"graph", body = %{type: type, url: url}, _context}, bot, _data) do
		Delta.add_fact(url, "og:type", type)
		Delta.add_fact(url, "og:image", body.image)
		Delta.add_fact(url, "og:title", body.title)
		:ok
	end

	def handle_cast_async({"link.tags", %{url: url, tags: tags }, _context}, bot, _data) do
		Enum.each(tags, fn(tag) ->
			tag = String.downcase(tag)
			Delta.add_fact(url, "og:tag", tag)
		end)
		:ok
	end

	def handle_cast({"link.history", _, context = %{channel: channel}}, bot, _data) do
		Delta.query_fact([
			[:url],
			[channel, "contains:url", :url]
		])
		|> Enum.each(fn x ->
			Bot.cast(bot, "bot.message", x, context)
		end)
		:ok
	end

	def handle_cast({"link.mine", _, context = %{channel: channel}}, bot, _data) do
		user = Bot.call(bot, "user.who", %{}, context)
		Delta.query_fact([
			[:url],
			[:sender, "user:key", user],
			[:sender, "share:url", :url]
		])
		|> Enum.flat_map(&(&1))
		|> Enum.each(fn x ->
			Bot.cast(bot, "bot.message", x, context)
		end)
		:ok
	end

	def handle_cast({"link.analysis", _, context = %{channel: channel}}, bot, _data) do
		user = Bot.call(bot, "user.who", %{}, context)
		Delta.query_fact([
			[:tag],
			[:sender, "user:key", user],
			[:sender, "share:url", :url],
			[:url, "og:tag", :tag],
		])
		|> Enum.flat_map(&(&1))
		|> Enum.group_by(&(&1))
		|> Enum.map(fn {key, value} -> {key, Enum.count(value)} end)
		|> Enum.filter(fn {key, value} -> value > 1 end)
		|> Enum.sort_by(fn {key, value} -> value end, &Kernel.>=/2)
		|> Enum.take(5)
		|> Enum.each(fn {x, count} ->
			Bot.cast(bot, "bot.message", "#{x} - #{count}", context)
		end)
		:ok
	end


	def handle_cast({"link.search.channel", %{tag: tag}, context = %{channel: channel}}, bot, _data) do
		Delta.query_fact([
			[:url],
			[:url, "og:tag", tag],
			[channel, "contains:url", :url]
		])
		|> Enum.each(fn x ->
			Bot.cast(bot, "bot.message", x, context)
		end)
		:ok
	end

end
