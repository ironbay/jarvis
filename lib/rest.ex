defmodule Jarvis.Rest do
	use Plug.Router
	import Plug.Conn
	import Plug.Conn.Utils
	alias Delta.Dynamic

	@pid :jarvis_bot

	plug :match
	plug :dispatch

	post "/external/shippo" do
		{:ok, data, _} = read_body(conn)
		Poison.decode!(data, as: %{})
		|> IO.inspect
		send_resp(conn, 200, "ok")
	end

	get "/external/nylas/callback" do
		conn = fetch_query_params(conn)
		state = Map.get(conn.params, "state")
		Bot.cast(@pid, "nylas.callback", conn.params, %{type: "nylas", channel: state})
		send_resp(conn, 200, "ok")
	end

	get "/external/nylas/hook" do
		conn = fetch_query_params(conn)
		send_resp(conn, 200, Map.get(conn.params, "challenge"))
	end

	post "/external/nylas/hook" do
		{:ok, data, _} = read_body(conn)
		Poison.decode!(data, as: %{})
		|> Map.get("deltas")
		|> Enum.each(&Bot.cast(@pid, "nylas.delta", &1, %{type: "nylas", sender: Dynamic.get(&1, ["object_data", "account_id"])}))
		send_resp(conn, 200, "ok")
	end

	get "/external/contextio/callback" do
		conn = fetch_query_params(conn)
		token = Map.get(conn.params, "contextio_token")
		Bot.cast(@pid, "contextio.callback", token, %{type: "contextio", sender: token})
		send_resp(conn, 200, "ok")
	end

	post "/external/contextio/hook" do
		{:ok, data, _} = read_body(conn)
		message = Poison.decode!(data, as: %{})
		Bot.cast(@pid, "contextio.message", message)

		send_resp(conn, 200, "ok")
	end

	post "/cast" do
		{:ok, data, _} = read_body(conn)
		%{
			"body" => body,
			"action" => action,
			"context" => context,
		} = Poison.decode!(data, as: %{}) |> IO.inspect
		Bot.cast(@pid, action, body, context)
		send_resp(conn, 200, "ok")
	end


	get ":all" do
		send_resp(conn, 200, "")
	end

	def start_link do
		{:ok, _} = Plug.Adapters.Cowboy.http __MODULE__, [], port: 4001
	end

end
