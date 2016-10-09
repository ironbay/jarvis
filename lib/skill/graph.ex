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

	def handle_call({"graph.node", node, _context}, bot, data = %{neo: neo}) do
		cypher = """
			MERGE (node:Node { key: {node}.key} })
			ON CREATE SET node.props += {node}, node.created = TIMESTAMP()
		"""
		Neo4j.Sips.query(Neo4j.Sips.conn, cypher, %{
			node: build(node)
		})
		:ok
	end

	def handle_call({"graph.triple", body = %{nodes: nodes, edges: edges}, _context}, bot, data = %{neo: neo}) do
		params =
			nodes
			|> Enum.map(fn {key, node} -> {key, build(node)} end)
			|> Enum.into(%{})
		create_nodes =
			nodes
			|> Enum.map(fn {key, node} ->
				"""
					MERGE (#{key}:Node { key: {#{key}}.key })
					ON CREATE SET #{key} += {#{key}}, #{key}.created = TIMESTAMP()
				"""
			end)
			|> Enum.join("\n")
		create_edges =
			edges
			|> Enum.map(fn [subject, pred, object] ->
				"""
					MERGE (#{subject})-[:#{pred}]->(#{object})
				"""
			end)
			|> Enum.join("\n")
		cypher = Enum.join([create_nodes, create_edges], "\n")
		Neo4j.Sips.query(Neo4j.Sips.conn, cypher, params)
		:ok
	end

	def build(node = %{type: type, token: token}) do
		Map.put(node, :key, "#{type}-#{token}")
	end
end
