defmodule Jarvis.Link do
	use Bot.Skill

	def begin(bot, []) do
		{:ok, %{}}
	end

	def handle_cast_async({"link.direct", %{url: url}, %{sender: sender, type: type, channel: channel}}, bot, _data) do
		Bot.call(bot, "graph.triple", %{
			a: %{
				type: "source",
				token: "#{type}-#{sender}",
				props: %{
					sender: sender,
					account: type,
				}
			},
			b: %{
				type: "link",
				token: url,
				props: %{
					url: url
				}
			},
			edge: "DID_SHARE"
		})
		:ok
	end

	def handle_cast_async({"graph", body = %{type: type, url: url}, _context}, bot, _data) do
		Bot.call(bot, "graph.triple", %{
			a: %{
				type: "link",
				token: url,
				props: %{},
			},
			b: %{
				type: type,
				token: url,
				props: body,
			},
			edge: "IS"
		})
		:ok
	end

	def handle_cast_async({"link.tags", %{url: url, tags: tags }, _context}, bot, _data) do
		Enum.each(tags, fn(tag) ->
			Bot.call(bot, "graph.triple", %{
				a: %{
					type: "link",
					token: url,
					props: %{},
				},
				b: %{
					type: "tag",
					token: tag,
					props: %{
						value: tag
					},
				},
				edge: "HAS_TAG"
			})
		end)
		:ok
	end

end
