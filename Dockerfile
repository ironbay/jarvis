FROM ironbay/elixir:master
ADD . .

CMD iex -S mix
