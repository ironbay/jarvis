defmodule Jarvis.Gmail.Register do
	use Bot.Skill

	@auth "https://accounts.google.com/o/oauth2/auth?scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fgmail.readonly&response_type=code&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&client_id=735523450636-n5snetq0dt23btueebn3aet2e5dgq0pe.apps.googleusercontent.com&access_type=offline"
	@token "https://www.googleapis.com/oauth2/v4/token"
	@client_id "735523450636-n5snetq0dt23btueebn3aet2e5dgq0pe.apps.googleusercontent.com"
	@client_secret "yKcrmA4qFZ3TkB6j-U7BCbzS"
	@redirect_uri "urn:ietf:wg:oauth:2.0:oob"


	def begin(bot, args) do
		Bot.cast(bot, "regex.add", {"^register gmail$", "gmail.register"})
		{:ok, %{}}
	end

	def handle_cast_async({"gmail.register", _, context}, bot, _state) do
		Bot.cast(bot, "bot.message", "To register go here and tell me the code you get #{@auth}", context)
		{_, %{text: code}, _} = Bot.wait(bot, context, ["chat.message"])
		HTTPoison.post(@token, {:form, [
			code: code,
			client_id: @client_id,
			client_secret: @client_secret,
			redirect_uri: @redirect_uri,
			grant_type: "authorization_code",
		]}, %{"Content-type" => "application/x-www-form-urlencoded"})
		:ok
	end
end


defmodule Jarvis.Gmail.Poller do
	use Bot.Skill
	alias Delta.Dynamic
	@interval 5000

	def begin(bot, [user, email, refresh]) do
		{:ok, _} = Gmail.User.start_mail(email, refresh)
		schedule(0)
		{:ok, %{
			user: user,
			email: email,
			refresh: refresh,
		}}
	end

	def handle_cast_async({"gmail.thread", id, context = %{sender: sender}}, bot, _state) do
		{:ok, thread} = Gmail.User.thread(sender, id)
		thread.messages
		|> Enum.flat_map(&(&1.payload.parts))
		|> Enum.map(fn part ->
			%{
				data: part.body.data,
				mime: part.mime_type,
			}
		end)
		|> Enum.each(&Bot.cast(bot, "email", &1, context))
		:ok
	end

	def schedule(time \\ @interval) do
		Process.send_after(self, {:scan, div(:erlang.system_time(:milli_seconds), 1000)}, @interval)
	end

	def handle_info({:scan, time}, bot, state) do
		schedule()
		state.email
		|> poll(time)
		|> cast(state.email, bot)
		{:ok, state}
	end

	def cast(threads, email, bot) do
		threads
		|> Enum.each(fn thread ->
			Bot.cast(bot, "gmail.thread", thread.id, %{type: "gmail", sender: email})
		end)
		threads
	end


	def since(threads, id) do
		threads
		|> Enum.filter(&(Map.get(&1, :history_id) > id ))
	end

	def poll(email, time) do
		{:ok, threads} = Gmail.User.threads(email, %{q: "newer: #{time}"})
		threads
	end

	def last([], id) do
		id
	end

	def last(threads, _id) do
		threads
		|> List.first
		|> Map.get(:history_id)
	end
end
