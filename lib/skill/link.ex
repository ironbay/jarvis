defmodule Jarvis.Link do
	use Bot.Skill

	def begin(bot, []) do
		{:ok, %{}}
	end

	def handle_cast_async({"link.direct", %{url: url}, %{sender: sender, type: type, channel: channel}}, bot, _data) do
		Bot.call(bot, "graph.triple", %{
			nodes: %{
				link: %{
					type: "link",
					token: url,
				},
				sender: %{
					type: "source",
					token: "#{type}/#{sender}"
				},
				# channel: %{
				# 	type: "channel",
				# 	token: "#{type}/#{channel}",
				# },
			},
			edges: [
				[:sender, "DID_SHARE", :link],
				# [:channel, "HAS_LINK", :link],
			]
		})
		:ok
	end

	def handle_cast_async({"graph", body = %{type: type, url: url}, _context}, bot, _data) do
		Bot.call(bot, "graph.triple", %{
			nodes: %{
				link: %{
					type: "link",
					token: url,
				},
				item: %{
					type: type,
					token: url,
				},
				image: %{
					type: "image",
					token: body.image,
				},
				title: %{
					type: "title",
					token: body.title,
				},
			},
			edges: [
				[:link, "IS", :item],
				[:item, "HAS_IMAGE", :image],
				[:item, "HAS_TITLE", :title],
			]
		})
		:ok
	end

	def handle_cast_async({"link.tags", %{url: url, tags: tags }, _context}, bot, _data) do
		Enum.each(tags, fn(tag) ->
			tag = String.downcase(tag)
			Bot.call(bot, "graph.triple", %{
				nodes: %{
					link: %{
						type: "link",
						token: url,
					},
					tag: %{
						type: "tag",
						token: tag,
					},
				},
				edges: [
					[:link, "HAS_TAG", :tag]
				]
			})
		end)
		:ok
	end

end
