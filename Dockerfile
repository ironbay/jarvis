FROM ironbay/elixir:master
ADD . .
RUN iex -S mix
