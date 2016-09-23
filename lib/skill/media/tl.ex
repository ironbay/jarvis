defmodule Jarvis.Media.TL do
	use Bot.Skill
	@server "irc.torrentleech.org"
	@port 7011
	@nick "jarvis"
	#
	# @server "chat.freenode.net"
	# @port 6667

	def begin(bot, []) do
		{:ok, client} = ExIrc.start_client!()
		ExIrc.Client.connect!(client, @server, @port)
		ExIrc.Client.logon(client, @nick, @nick, @nick, @nick)
		ExIrc.Client.add_handler(client, self)
		{:ok, %{
			client: client
		}}
	end

	def handle_info({:connected, _server, _port}, state = %{client: client}) do
		ExIrc.Client.join(client, "#tlannounces")
		|> IO.inspect
		{:noreply, state}
	end

	def handle_info(msg, state) do
		IO.inspect(msg)
		{:noreply, state}
	end
end
