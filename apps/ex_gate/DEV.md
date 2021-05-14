## Local development

Env vars needed:

    GOOGLE_CLIENT_ID: the OAuth2 google client id
    
Just run:

    docker-compose up --build -d

This will expose the following services on `localhost`:

- postgres instance, port 5432
- pgadmin instance, on port 8082

Since the ports are mapped to host machine, `ex_gate` will be able to use `localhost` as database host. If, in future, there will be the need to deploy the app in the local compose cluster, the name of the host must be changed to `postgres`, of course.

If you want to destroy the environment, just run:

    `docker-compose down -v`

Note that `-v` is important because there are mounted volumes.
