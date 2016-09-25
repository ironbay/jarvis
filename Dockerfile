FROM ironbay/elixir:master

ADD . .
RUN mix deps.get

CMD iex -S mix
