defmodule Reddit do
	alias Delta.Dynamic
	@root "https://www.reddit.com/api/v1"
	@oauth "https://oauth.reddit.com"

	def token do
		token("Fabagemaf06", "dOKNOkRLayOJ")
	end

	def token(username, password) do
		body = URI.encode_query([grant_type: "password", username: username, password: password])
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

	def get(path, token, query \\ []) do
		path
		|> url(query)
		|> HTTPoison.get!([
			token_header |
			headers
		])
		|> Map.get(:body)
		|> Poison.decode!
	end

	def post(path, token, body \\ [], query \\ []) do
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

	def inbox(since \\ 0, token \\ token()) do
		"/message/inbox"
		|> get(token)
		|> Dynamic.get(["data", "children"])
		|> Stream.map(&Map.get(&1, "data"))
		|> Stream.map(&Map.take(&1, ["id", "body", "author", "created"]))
		|> Stream.map(&Dynamic.keys_to_atoms/1)
		|> Enum.filter(fn %{created: created} -> created > since end)
	end

	def send(to, subject, text \\ token()) do
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
