defmodule Delta do
	use Delta.Base
	use Delta.Plugin.Mutation
	use Delta.Plugin.Query
	use Delta.Plugin.Watch
	use Delta.Plugin.Fact

	@read {Delta.Stores.Postgres, :postgres}

	@writes [
		{Delta.Stores.Postgres, :postgres}
	]

end
