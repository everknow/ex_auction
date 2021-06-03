FROM elixir:1.11.4-alpine as BUILD
RUN apk update && apk add openssl-dev

RUN mix local.hex --force
RUN mix local.rebar --force

# Building arguments
ARG GOOGLE_CLIENT_ID
ARG DATABASE_NAME
ARG DATABASE_USER
ARG DATABASE_PASSWORD
ARG DATABASE_HOSTNAME
ARG DATABASE_PORT

COPY . /app
WORKDIR /app

RUN mix deps.get --only prod
RUN MIX_ENV=prod mix release ex_auctions

FROM alpine:latest 
RUN apk update && apk add ncurses openssl-dev
RUN mkdir /app
COPY --from=BUILD /app/_build/prod/ex_auctions-0.1.0.tar.gz /app
COPY docker-entrypoint.sh /app
WORKDIR /app
RUN tar xzfv ex_auctions-0.1.0.tar.gz

ENTRYPOINT [ "/app/docker-entrypoint.sh" ]
CMD ["start"]


