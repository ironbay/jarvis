defmodule Reddit do
	@root "https://www.reddit.com/api/v1"
	@oauth "https://oauth.reddit.com"

	defp token do
		body = URI.encode_query([grant_type: "password", username: "-SwearWord-", password: "solodolo1?"])
		"#{@root}/access_token"
		|> HTTPoison.post!(body, [
			{"Authorization", "Basic RXpzbXIyZk1PVUs2VEE6Z3o5Z0ViQllBcDVrOGlheDBjS1lVeFoyUExB"} | headers
		])
		|> Map.get(:body)
		|> Poison.decode!
		|> Map.get("access_token")
	end

	defp token_header do
		{"Authorization", "bearer #{token}"}
	end

	def get(path, query \\ []) do
		path
		|> url(query)
		|> HTTPoison.get!([
			token_header |
			headers
		])
		|> Map.get(:body)
		|> Poison.decode!
	end

	def post(path, body \\ [], query \\ []) do
		body = URI.encode_query(body)
		path
		|> url(query)
		|> HTTPoison.post!(body, [
			token_header |
			headers
		])
		|> Map.get(:body)
		|> Poison.decode!
	end

	defp url(path, query \\ []) do
		query = URI.encode_query(query)
		"#{@oauth}#{path}?#{query}"
	end

	def unread do
		"/message/unread"
		|> get
	end

	def send(to, subject, text) do
		"/api/compose"
		|> post([
			to: to,
			subject: subject,
			text: text,
			api_type: "json",
		])
	end

	defp headers do
		[
			{"Content-Type", "application/x-www-form-urlencoded"},
			{"User-Agent", "Jarvis by -SwearWord-"}
		]
	end
end
