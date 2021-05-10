ex_auction
----------


an off-chain and on-chain auction service

Requirements [here](../REQUIREMENTS)

## Local development

Just run

    docker-compose up --build -d

this will expose the following services on `localhost`:

- postgres instance, port 5432
- pgadmin instance, on port 8082

Since the ports are mapped to host machine, `ex_auction` will be able to use `localhost` as database host. If, in future, there will be the need to deploy the app in the local compose cluster, the name of the host must be changed to `postgres`, of course.
