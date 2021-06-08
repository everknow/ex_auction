FROM elixir:1.11.4-alpine as BUILD
RUN apk update && apk add git openssh openssl-dev

RUN mkdir /root/.ssh/
COPY ssh/id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa
RUN ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

RUN mix local.hex --force
RUN mix local.rebar --force

COPY . /app
WORKDIR /app

RUN mix deps.get --only prod
RUN mix deps.compile --all
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


