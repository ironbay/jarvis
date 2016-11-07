defmodule Delta do
	use Delta.Base
	use Delta.Plugin.Mutation
	use Delta.Plugin.Query
	use Delta.Plugin.Watch
	use Delta.Plugin.Fact

	@interceptors [
		Delta.Test.Interceptor
	]

	@writes [
		{Delta.Stores.Cassandra, %{}}
	]

	@read {Delta.Stores.Cassandra, %{}}

end
