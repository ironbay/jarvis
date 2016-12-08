defmodule Jarvis.Presence do
	use Bot.Skill
	@interval 5 * 1000

	def begin(bot, ips) do
		Bot.cast(bot, "regex.add", {"cast speech (?P<text>.+)", "chromecast.speech"})
		schedule(@interval)
		{:ok, %{
			ips: ips,
			current: ping(ips),
		}}
	end

	defp schedule(interval) do
		Process.send_after(self, {:do}, interval)
	end

	def handle_info({:do}, bot, data) do
		next = ping(data.ips)
		data.ips
		|> Enum.each(fn ip ->
			old = Map.get(data.current, ip)
			new = Map.get(next, ip)
			case {old, new} do
				{true, false} -> Bot.cast(bot, "presence.inactive", ip, %{type: "network", sender: ip})
				{false, true} -> Bot.cast(bot, "presence.active", ip, %{type: "network", sender: ip})
				_ ->
			end
		end)
		schedule(@interval)
		{:ok, %{
			data |
			current: next
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

	def ping(ips) do
		ips
		|> ParallelStream.map(fn ip ->
			count =
				1..5
				|> Enum.take_while(fn _ ->
					{result, _} =
						System.cmd("nmap", [
							"-sn", ip,
						])
					!String.contains?(result, "1 host up")
				end )
				|> Enum.count
			{ip, count < 3}
		end)
		|> Enum.into(%{})
	end

	def notify(ip, true, false) do

	end

	def notify(ip, false, true) do
	end

	def notify(_, _, _) do
	end


end
