defmodule Jarvis.Media.TL do
	use Bot.Skill
	@server "irc.torrentleech.org"
	@port 7011
	@nick "jarvis"
	#
	# @server "chat.freenode.net"
	# @port 6667

	def begin(bot, []) do
		Bot.cast(bot, "regex.add", {"\\<(?P<category>.+)\\> Name:'(?P<name>[^']+)'.+http[^\\d]+(?P<id>\\d+)", "torrent.upload"})
		{:ok, client} = ExIrc.start_client!()
		ExIrc.Client.add_handler(client, self)
		ExIrc.Client.connect!(client, @server, @port)
		{:ok, %{
			client: client
		}}
	end

	def handle_info({:connected, _server, _port}, state = %{data: %{client: client}}) do
		ExIrc.Client.logon(client, "", @nick, @nick, @nick)
		{:noreply, state}
	end

	def handle_info(:logged_in, state = %{data: %{client: client}}) do
		ExIrc.Client.join(client, "#tlannounces")
		{:noreply, state}
	end

	def handle_info({:received, data, _sender, _channel}, state = %{bot: bot, data: %{client: client}}) do
		text = String.Chars.to_string(data)
		Bot.cast(bot, "chat.message", %{
			text: text
		})
		{:noreply, state}
	end

	def handle_info(msg, state) do
		{:noreply, state}
	end
end
