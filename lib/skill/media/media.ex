defmodule Jarvis.Media do
	use Bot.Skill

	def begin(bot, args) do
		Bot.cast(bot, "regex.add", {"show me (a|an) (?P<type>.+)$", "media.search"})
		Bot.cast(bot, "regex.add", {"show me (a|an) (?P<type>.+) about (?P<tag>.+)$", "media.search.tag"})
		# Bot.cast(bot, "locale.add", {"graph", "This <%= type %> is lit"})
		Bot.cast(bot, "locale.add", {"media.result", "<%= url %>"})
		{:ok, %{
			"video" => %{},
			"music.song" => %{},
		}}
	end

	def handle_cast({"graph", body = %{url: url, type: type}, context}, bot, data) do
		{:ok, Kernel.put_in(data, [type, url], body)}
	end

	def handle_cast({"media.search", body = %{type: type}, context}, bot, data) do
		cypher = """
			MATCH (node:Node { type: {type} })
			RETURN node
		"""
		{:ok, data} = Neo4j.Sips.query(Neo4j.Sips.conn, cypher, %{
			type: type
		})
		result =
			data
			|> Enum.random
			|> Map.get("node")
		result = for {key, val} <- result, into: %{}, do: {String.to_atom(key), val}
		Bot.cast(bot, "media.result", result, context)
		:ok
	end

	def handle_cast({"media.search.tag", body = %{type: type, tag: tag}, context}, bot, data) do
		cypher = """
			MATCH (link)-[:IS]->(node { type: {type} })
			MATCH (tag { key: {tag} })
			MATCH (link)-[:HAS_TAG]->(tag)
			RETURN DISTINCT node
		"""
		{:ok, data} = Neo4j.Sips.query(Neo4j.Sips.conn, cypher, %{
			type: type,
			tag: "tag-#{tag}"
		})
		result =
			data
			|> Enum.random
			|> Map.get("node")
		result = for {key, val} <- result, into: %{}, do: {String.to_atom(key), val}
		Bot.cast(bot, "media.result", result, context)
		:ok
	end
end
