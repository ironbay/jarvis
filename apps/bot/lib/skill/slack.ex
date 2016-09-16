defmodule Bot.Skill.Slack do
	use Bot.Skill

	def begin(bot, [token, broadcast]) do
		{:ok, conn} = Bot.Skill.Slack.Conn.start_link(token)
		{:ok, %{
			broadcast: broadcast,
			conn: conn
		}}
	end

	def on({"chat.response", text, %{type: "slack", channel: channel}}, bot, data = %{conn: conn}) do
		send(conn, {:message, text, channel})
		{:ok, data}
	end

	def on({"chat.broadcast", text, %{}}, bot, data = %{conn: conn, broadcast: broadcast}) when broadcast != "" do
		send(conn, {:message, text, broadcast})
		{:ok, data}
	end

	def handle_info({:message, body, context}, state = %{bot: bot}) do
		Bot.broadcast(bot, "chat.message", body, context)
		{:noreply, state}
	end
end

defmodule Bot.Skill.Slack.Conn do
	use Slack

	def handle_connect(slack) do
	end

	def handle_message(message = %{
		type: "message",
		user: user,
		text: text,
		channel: channel,
	}, state) do
		# TODO: Temporary hack to get skill pid
		Process.info(self())
		|> Access.get(:links)
		|> Enum.at(0)
		|> send({:message, text, %{
			type: "slack",
			sender: user,
			channel: channel,
		}})
		{:ok, state}
	end

	def handle_message(_,_), do: :ok

	def handle_info({:message, text, channel}, state) do
		send_message(text, channel, state)
		{:noreply, state}
	end

	def handle_info(_, _), do: :ok
end
