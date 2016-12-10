defmodule Jarvis.Presence do
	use Bot.Skill
	@interval 5 * 1000

	def begin(bot, [ip]) do
		Bot.cast(bot, "regex.add", {"cast speech (?P<text>.+)", "chromecast.speech"})
		schedule(@interval)
		{:ok, %{
			ip: ip,
			status: ping(ip),
		}}
	end

	defp schedule(interval) do
		Process.send_after(self, {:do}, interval)
	end

	def handle_info({:do}, bot, data) do
		next = ping(data.ip)
		case {data.status, next} do
			{true, false} -> Bot.cast(bot, "presence.inactive", data.ip, %{type: "network", sender: data.ip})
			{false, true} -> Bot.cast(bot, "presence.active", data.ip, %{type: "network", sender: data.ip})
			_ -> :skip
		end
		schedule(@interval)
		{:ok, %{
			data |
			status: next
		}}
	end

	def handle_cast_async({"presence.active", ip, _context}, bot, _data) do
		IO.puts("Active #{ip}")
		Bot.call(bot, "chromecast.speak", "Welcome home")
		:ok
	end

	def handle_cast_async({"presence.inactive", ip, _context}, _bot, _data) do
		IO.puts("Inactive #{ip}")
		:ok
	end

	def ping(ip) do
		{_, code} =
			System.cmd("bash", [
				"-c", "ip -s -s neigh flush all && arp -an | grep #{ip} | grep incomplete",
			])
			|> IO.inspect
		code != 0
	end

end
