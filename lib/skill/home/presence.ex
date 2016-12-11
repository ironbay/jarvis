defmodule Jarvis.Presence do
	use Bot.Skill
	@interval 5 * 1000

	def begin(bot, [network, ip]) do
		Bot.cast(bot, "regex.add", {"cast speech (?P<text>.+)", "chromecast.speech"})
		schedule(@interval)
		{:ok, %{
			ip: ip,
			status: ping(ip),
			context: %{
				type: "wifi",
				network: network,
				sender: ip,
			}
		}}
	end

	defp schedule(interval) do
		Process.send_after(self, {:do}, interval)
	end

	def handle_info({:do}, bot, data) do
		next = ping(data.ip)
		case {data.status, next} do
			{true, false} -> Bot.cast(bot, "presence.inactive", data.ip, data.context)
			{false, true} -> Bot.cast(bot, "presence.active", data.ip, data.context)
			_ -> :skip
		end
		schedule(@interval)
		{:ok, %{
			data |
			status: next
		}}
	end

	def handle_cast_async({"presence.active", ip, _context}, bot, data) do
		IO.puts("Active #{ip}")
		:ok
	end

	def handle_cast_async({"presence.inactive", ip, _context}, _bot, _data) do
		IO.puts("Inactive #{ip}")
		:ok
	end

	def ping(ip) do
		{_, code} =
			System.cmd("bash", [
				"-c", "sudo arp-scan -l | grep #{ip}",
			])
		code == 0
	end

end
