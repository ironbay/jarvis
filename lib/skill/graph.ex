defmodule Jarvis.Graph do
	use Bot.Skill

	def begin(bot, args) do
		{:ok, {}}
	end

	def handle_cast_async("link.clean", %{url: url, mime: mime}, state) do

		:ok
	end

	def build(node = %{type: type, token: token}) do
		Map.put(node, :key, "#{type}-#{token}")
	end
end
