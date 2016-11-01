defmodule Jarvis.Link do
	alias Delta.Plugin.Fact
	use Bot.Skill

	def begin(bot, []) do
		Bot.cast(bot, "regex.add", {"link history", "link.history"})
		Bot.cast(bot, "regex.add", {"^my links$", "link.mine"})
		Bot.cast(bot, "regex.add", {"^what do I like$", "link.analysis"})
		Bot.cast(bot, "regex.add", {"links about (?<tag>.+) from here", "link.search.channel"})
		{:ok, Delta.start_session(Delta, "jarvis")}
	end

	def handle_cast_async({"link.direct", %{url: url}, %{sender: sender, type: type, channel: channel}}, bot, session) do
		Fact.add_fact(session, sender, "share:url", url)
		Fact.add_fact(session, channel, "contains:url", url)
		:ok
	end

	def handle_cast_async({"graph", body = %{type: type, url: url}, _context}, bot, session) do
		Fact.add_fact(session, url, "og:type", type)
		Fact.add_fact(session, url, "og:image", body.image)
		Fact.add_fact(session, url, "og:title", body.title)
		:ok
	end

	def handle_cast_async({"link.tags", %{url: url, tags: tags }, _context}, bot, session) do
		Enum.each(tags, fn(tag) ->
			tag = String.downcase(tag)
			Fact.add_fact(session, url, "og:tag", tag)
		end)
		:ok
	end

	def handle_cast({"link.history", _, context = %{channel: channel}}, bot, session) do
		Fact.query(session, [
			[:url],
			[channel, "contains:url", :url]
		])
		|> Enum.each(fn x ->
			Bot.cast(bot, "bot.message", x, context)
		end)
		:ok
	end

	def handle_cast({"link.mine", _, context = %{channel: channel}}, bot, session) do
		{user, _} = Bot.call(bot, "user.who", %{}, context)
		Fact.query(session, [
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

	def handle_cast({"link.analysis", _, context = %{channel: channel}}, bot, session) do
		{user, _} = Bot.call(bot, "user.who", %{}, context)
		Fact.query(session, [
			[:url],
			[:sender, "user:key", user],
			[:sender, "share:url", :url],
		])
		|> Enum.flat_map(&(&1))
		|> Enum.flat_map(fn x ->
			Fact.query(session, [
				[:tag],
				[x, "og:tag", :tag]
			])
		end)
		|> Enum.group_by(&(&1))
		|> Enum.map(fn {key, value} -> {key, Enum.count(value)} end)
		|> Enum.sort_by(fn {key, value} -> value end)
		|> Enum.take(5)
		|> IO.inspect
		|> Enum.each(fn {x, _} ->
			Bot.cast(bot, "bot.message", x, context)
		end)
		:ok
	end


	def handle_cast({"link.search.channel", %{tag: tag}, context = %{channel: channel}}, bot, session) do
		Fact.query(session, [
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
