FROM ironbay/elixir:master

ENV MIX_ENV=prod
RUN pacman --noconfirm -S gcc
RUN pacman --noconfirm -S cmake


ADD . .
RUN mix deps.get
RUN mix clean
RUN mix compile
# RUN mix release
# ADD vm.args ./apps/server/rel/server/running-config/vm.args


ADD run run
EXPOSE 4001

CMD iex -S mix
