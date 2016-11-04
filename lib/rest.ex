defmodule Jarvis.Rest do
	use Plug.Router
	import Plug.Conn
	import Plug.Conn.Utils

	plug :match
	plug :dispatch

	get "/external/contextio/callback" do
		conn = fetch_query_params(conn)
		token = Map.get(conn.params, "contextio_token")
		Bot.cast(:jarvis, "contextio.callback", token, %{type: "contextio", sender: token})
		send_resp(conn, 200, "ok")
	end

	post "/external/contextio/hook" do
		read_body(conn)
		|> IO.inspect

		send_resp(conn, 200, "ok")
	end


	get ":all" do
		send_resp(conn, 200, "")
	end

	def start_link do
		{:ok, _} = Plug.Adapters.Cowboy.http __MODULE__, []
	end

end
