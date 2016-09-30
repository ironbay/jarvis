defmodule Jarvis.Graph do
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

	def handle_call({"graph.node", body, _context}, bot, data = %{neo: neo}) do
		{key, props} = node(body)
		cypher = """
			MERGE (node:Node { key: {key} })
			SET node += {props}
		"""
		Neo4j.Sips.query(Neo4j.Sips.conn, cypher, %{
			key: key,
			props: props,
		})
		:ok
	end

	def handle_call({"graph.triple", body = %{a: a, b: b, edge: edge}, _context}, bot, data = %{neo: neo}) do
		{a_key, a_props} = build(a)
		{b_key, b_props} = build(b)
		cypher = """
			MERGE (a:Node { key: {a_key} })
			ON CREATE SET a += {a_props}

			MERGE (b:Node { key: {b_key} })
			ON CREATE SET b += {b_props}

			MERGE (a)-[r:#{edge}]->(b)
			SET r.created = TIMESTAMP()
		"""
		{:ok, _} = Neo4j.Sips.query(Neo4j.Sips.conn, cypher, %{
			a_key: a_key,
			b_key: b_key,
			a_props: a_props,
			b_props: b_props,
		})
		:ok
	end

	def build(input = %{props: nil}) do
		build(Map.put(input, :props, %{}))
	end

	def build(%{props: props, type: type, token: token}) do
		key = "#{type}-#{token}"
		{key,
			props
			|> Map.put(:type, type)
		}
	end

end
