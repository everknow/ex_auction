# ExContractCache


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_contract_cache` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_contract_cache, "~> 0.1.0"}
  ]
end
```

## Design

The `ex_contract_cache` application exposes two endpoints:

### NFTs list

|            |         |  |
| -----------|--------- |--- |
| **Path**    | /page   |  |
| **Method**     | GET   |  |
| **Authorization** | Bearer token | mandatory |
| **start_index** | starting nft | mandatory |
| **limit** | number of nfts wanted | mandatory|
| **owner_address** | a specific address | optional|


[ ADD SECOND ENDPOINT HERE ]

## App Configuration

You need to define the following app configuration:

|     Name       |    Description     |
| -----------|--------- |
| **google_client_id** | the google client id to verify authentication token |
|**port** | the http(s) port to serve the app
|**scheme** | :http | :https
|**base_uri** | base uri to access the smart contract
|**contract** | the contract
|**page_size** | the size of the page to return
|**time** | the time to wait before checking the redis case
|**redis_host** | redist host |
|**redis_port** | redis port |


## Usage

In order to use the app, you should define your own cowboy entry in the main application and serve the handler, something like this (in your `Plug.Router`):

    forward("your_endpoint", to: ExContractCache.Endpoints.NFT.Receiver)
