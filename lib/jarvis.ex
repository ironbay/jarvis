defmodule Jarvis do
	use Application
#
	# See http://elixir-lang.org/docs/stable/elixir/Application.html
	# for more information on OTP Applications
	def start(_type, _args) do
		import Supervisor.Spec, warn: false
		config = read_config
		Node.connect(:"jarvis@10.42.105.192")
		:syn.init
		# Define workers and child supervisors to be supervised
		children = [
			# Starts a worker by calling: Bot.Worker.start_link(arg1, arg2, arg3)
			worker(Postgrex, [[hostname: "10.42.16.225", username: "postgres", password: "postgres", database: "postgres", name: :postgres]]),
			worker(Jarvis.Rest, []),
			supervisor(Bot.Skill.Supervisor, [[name: :skills]]),
			worker(Jarvis.Bootstrap, [config]),
			worker(Delta.Server, [Jarvis.Handler, 12000]),
		]


		# See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
		# for other strategies and supported options
		opts = [strategy: :rest_for_one, name: Jarvis]
		Supervisor.start_link(children, opts)
	end

	def read_config() do
		:jarvis
		|> Application.get_env(:config)
		|> File.read!
		|> Poison.decode!(keys: :atoms)
	end
end

defmodule Jarvis.Bootstrap do
	use GenServer

	def start_link(config) do
		GenServer.start_link(__MODULE__, [config])
	end

	def init([config]) do
		config
		|> Map.get(:skills)
		|> Enum.each(fn %{module: module, args: args} ->
			Bot.Skill.Supervisor.enable_skill(:skills, :jarvis_bot, String.to_existing_atom("Elixir." <> module), args)
		end)

		{:ok, []}
	end
end
