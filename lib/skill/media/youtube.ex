defmodule Jarvis.Media.Youtube do
	use Bot.Skill
	@interval 1000 * 60 * 60

	def begin(bot, [path]) do
		schedule(0)
		{:ok, %{
			url: "https://www.youtube.com/#{path}/videos?view=15&shelf_id=0&sort=dd",
		}}
	end

	defp schedule(interval) do
		Process.send_after(self(), {:poll}, interval)
	end

	def handle_info({:poll}, bot, data = %{url: url}) do
		schedule(@interval)
		url
		|> HTTPoison.get!
		|> Map.get(:body)
		|> Floki.find(".yt-uix-tile-link")
		|> Floki.attribute("href")
		|> Stream.filter(&String.starts_with?(&1, "/watch"))
		|> Enum.each(&Bot.cast(bot, "link", %{url: "https://youtube.com#{&1}"}))
		:ok
	end

end
