defmodule Jarvis.ContextIO.Register do
	use Bot.Skill
	alias Delta.Plugin.Fact
	alias Jarvis.ContextIO.API

	@connect "https://api.context.io/lite/connect_tokens"

	def begin(bot, args) do
		Bot.cast(bot, "regex.add", {"^register email$", "contextio.register"})
		{:ok, Delta.session(Delta)}
	end

	def handle_cast_async({"contextio.register", _, context}, bot, session) do
		user = Bot.call(bot, "user.who", %{}, context)
		case Fact.query(session, [
			[:sender],
			[:sender, "user:key", user],
			[:sender, "context:type", "contextio"]
		]) |> List.first do

			_ ->
				Bot.cast(bot, "bot.message", "What email would you like to register?", context)
				{_, %{raw: email}, _} = Bot.wait(bot, context, ["chat.email"])
				result = API.post_data!("/connect_tokens", %{"email" => email, "callback_url" => "http://localhost:4000/oauth/contextio/callback"})
				%{"browser_redirect_url" => url, "token" => token} = result
				Bot.cast(bot, "bot.message", "Go here #{url}", context)
				{_, token, _} = Bot.wait(bot, %{type: "contextio", sender: token}, ["contextio.callback"])

				%{
					"account" => %{
						"id" => id
					}
				} = API.get_data!("/connect_tokens/#{token}")

				Fact.add_fact(session, id, "context:type", "contextio")
				Fact.add_fact(session, id, "user:key", user)
				Fact.add_fact(session, id, "contextio:email", user)
			_ ->
				Bot.cast(bot, "bot.message", "We already have you set up", context)
		end

		:ok
	end
end

defmodule Jarvis.ContextIO.API do
	use HTTPoison.Base

	@base "https://api.context.io/2.0"
	@creds OAuther.credentials(consumer_key: "ujc5wbrg", consumer_secret: "RNBLctrIfXwrbkvn")


	def post_data!(url, body) do
		url = @base <> url
		{headers, params} =
			OAuther.sign("post", url, body |> Enum.to_list, @creds)
			|> OAuther.header
		post!(url, {:form, params}, [headers], timeout: 30000).body
	end

	def get_data!(url, query \\ []) do
		url = @base <> url
		{headers, params} =
			OAuther.sign("get", url, query |> Enum.to_list, @creds)
			|> OAuther.header
		get!(url, [headers], params: params).body
	end

	defp process_response_body(body) do
		body
		|> Poison.decode!
	end
end
