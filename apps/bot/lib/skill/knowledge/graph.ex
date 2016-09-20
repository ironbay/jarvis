defmodule Bot.Skill.Graph do
	use Bot.Skill

	def begin(bot, args) do
		{:ok, neo} = Neo4j.Sips.start_link(url: "http://neo.ironbay.digital", basic_auth: [
			username: "neo4j",
			password: "9TcGy$w55]NmAv@#F,"
		])
		{:ok, %{
			neo: neo
		}}
	end

	def on({"link.direct", %{url: url }, context}, bot, data= %{neo: neo}) do
		cypher = """
			MERGE (source:Source { key: {source}.type + "-" + {source}.sender })
			ON CREATE SET source.user = {source}.sender, source.type = {source}.type

			MERGE (channel:Channel { key: {source}.channel })

			MERGE (link:Link { url: {url} })
			MERGE (source)-[r:DID_SEND]->(link)-[:IN_CHANNEL]->(channel)
			SET r.created = TIMESTAMP()
		"""
		{:ok, _ } = Neo4j.Sips.query(Neo4j.Sips.conn, cypher, %{
			source: context,
			url: url,
		})
		{:ok, data}
	end

	def on({"link.tags", %{url: url, tags: tags }, context}, bot, data= %{neo: neo}) do
		cypher = """
			MERGE (link:Link { url: {url} })
			WITH link
			UNWIND {tags} as value
			MERGE (tag:Tag { value: value })
			MERGE (link)-[:HAS_TAG]->(tag)
		"""
		{:ok, _ } = Neo4j.Sips.query(Neo4j.Sips.conn, cypher, %{
			tags: tags,
			url: url,
		})
		{:ok, data}
	end

end
