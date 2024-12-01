FROM elixir:1.14

# Install hex package manager
RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app

CMD [ "/bin/bash", "-c", "mix deps.get ; mix phx.server" ]
