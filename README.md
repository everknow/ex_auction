# ExAuction - Umbrella application

## Components implemented:

1. Auctions manager (name: [ExAuctionsManager](apps/ex_auctions_manager/README.md)). It's resposible to implement the auction logic, exposing proper endpoints.
2. Gate: (name: [ExGate](apps/ex_gate/README.md)). It's responsible to handle authentication and token generation to access all the other endpoints.

### Setup dev dependencies:

```shell
docker-compose up --build -d
```

This will expose the following services on `localhost`:

- postgres instance, port 5432
- pgadmin instance, on port 8082

### Teardown dev dependencies:

```shell
docker-compose down -v
```

Note that `-v` is important because there are mounted volumes.

### Development roadmap: [Plan](PLAN.md)

### Demo1: [Use cases](doc/demo1_use_cases.md)
