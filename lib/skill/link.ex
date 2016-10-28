defmodule Jarvis.Link do
	alias Delta.Plugin.Fact
	use Bot.Skill

	def begin(bot, []) do
		{:ok, Delta.start_session(Delta, "jarvis")}
	end

	def handle_cast_async({"link.direct", %{url: url}, %{sender: sender, type: type, channel: channel}}, bot, session) do
		encoded = URI.encode_www_form(url)
		Fact.add_fact(session, sender, "share:url", encoded)
		Fact.add_fact(session, channel, "contains:url", encoded)
		:ok
	end

	def handle_cast_async({"graph", body = %{type: type, url: url}, _context}, bot, session) do
		encoded = URI.encode_www_form(url)
		Fact.add_fact(session, encoded, "og:type", type)
		Fact.add_fact(session, encoded, "og:image", body.image)
		Fact.add_fact(session, encoded, "og:title", body.title)
		:ok
	end

	def handle_cast_async({"link.tags", %{url: url, tags: tags }, _context}, bot, session) do
		encoded = URI.encode_www_form(url)
		Enum.each(tags, fn(tag) ->
			tag = String.downcase(tag)
			Fact.add_fact(session, encoded, "og:tag", tag)
		end)
		:ok
	end

end
