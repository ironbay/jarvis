defmodule Jarvis.Package do
	use Bot.Skill

	@matches [
		{:fedex, ~r/\d{15}/i},
		{:fedex, ~r/\d{12}/i},
		{:fedex, ~r/\d{20}/i},
	]

	def begin(bot, []) do
		Bot.cast(bot, "regex.add", {"^list packages$", "package.list"})
		{:ok, {}}
	end

	def handle_cast_async({"package.list", _, context}, bot, data) do
		user = Bot.call(bot, "user.who", %{}, context)
		Delta.query_fact([
			[:account],
			[:account, "user:key", user],
			[:account, "context:type", "contextio"],
			[:account, "email:key", :email],
			[:email, "package:number", :package]
		])
		|> IO.inspect
		:ok
	end


	def handle_cast_async({"email", %{content: content, key: key}, context}, bot, data) do
		@matches
		|> Enum.flat_map(&scan(&1, content))
		|> Enum.uniq_by(&Map.get(&1, :number))
		|> Enum.filter(fn package ->
			Jarvis.Shippo.status(package.number, package.type)
			|> Map.get("tracking_status") !== nil
		end)
		|> Enum.map(fn package ->
			Delta.add_fact(context.sender, "package:number", package.number)
			Delta.add_fact(package.number, "package:type", Atom.to_string(package.type))
			Delta.add_fact(package.number, "package:email", key)
			Jarvis.Shippo.track(package.number, package.type)
			Bot.cast(bot, "package", package, context)
		end)
		:ok
	end

	defp scan({type, regex}, content) do
		Regex.scan(regex, content)
		|> Enum.map(&( %{type: type, number: List.first(&1)}))
	end
end

defmodule Jarvis.Shippo do
	@base "https://api.goshippo.com"

	def status(number, carrier) do
		get_data!("/tracks/#{carrier}/#{number}")
	end

	def track(number, carrier) do
		post_data!("/tracks/", tracking_number: number, carrier: carrier)
	end

	def post_data!(url, params) do
		url = @base <> url
		HTTPoison.post!(url, {:form, params}, [{"Authorization", "ShippoToken shippo_test_81c18ad3ec5cd9bbce3614cc82a150bf8ab47750"}]).body
		|> Poison.decode!
	end

	def get_data!(url) do
		url = @base <> url
		HTTPoison.get!(url, [{"Authorization", "ShippoToken shippo_test_81c18ad3ec5cd9bbce3614cc82a150bf8ab47750"}]).body
		|> Poison.decode!
	end
end
