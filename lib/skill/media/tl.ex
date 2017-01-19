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
		ExIrc.Client.add_handler(client, self)
		ExIrc.Client.connect!(client, @server, @port)
		{:ok, %{
			client: client
		}}
	end

	def handle_info({:connected, _server, _port}, _bot, data = %{client: client}) do
		ExIrc.Client.logon(client, "", @nick, @nick, @nick)
		:ok
	end

	def handle_info(:logged_in, _bot, data = %{client: client}) do
		ExIrc.Client.join(client, "#tlannounces")
		:ok
	end

	def handle_info({:received, data, _sender, _channel}, bot, state = %{client: client}) do
		text = String.Chars.to_string(data)
		{:ok, regex} = Regex.compile("\\<(?P<category>.+)\\> Name:'(?P<name>[^']+)'.+http[^\\d]+(?P<id>\\d+)")
		case Regex.named_captures(regex, text) do
			data ->
				parsed = for {key, val} <- data, into: %{}, do: {String.to_atom(key), val}
				Bot.cast(bot, "torrent.upload", parsed)
		end
		:ok
	end

	def handle_info(:disconnected, bot, state = %{client: client}) do
		:stop
	end

	def handle_info(msg, bot, state) do
		:ok
	end
end
