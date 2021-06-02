# API

The base uris reported here (http://localhost:808(0|1|2)) will be substituted by the domain name once in production.

## Offers endpoints

We call `offers` the bids placed for what we call `blind auctions`, where the user can bid with just the artwork info, start/end date and auction base price. A bid can be successful or not, and if a successful bid causes a previous bidder being outbid, its client will receive a notification with the proper info.

Base url: `http://localhost:8081/api/v1/offers`

### Endpoints

Offer creation

    Method: POST
    Path: /
    Headers:
        Authorization: Bearer <TOKEN> 
        Content-Type: application/json
    Body:
        {
            "auction_id": <AUCTION_ID>, (integer)
            "bid_value": <BID>, (integer)
            "bidder": "<BIDDER>"
        }

Eventually outbid users will receive the ws notification:

    {
        notification_type: "outbid", 
        auction_id: <auiction_id>
    }
    
#### Successful response:

    HTTP Status: 201

    Body:
        {
            "auction_id": <AUCTION_ID>, (integer)
            "bid_value": <BID>, (integer)
            "bidder": "<BIDDER>"
        }
      
#### Error response:

    HTTP Status: 422

    Body:
        {
            "auction_id": <AUCTION_ID>)
            "bid_value": <BID>,
            "bidder": "<BIDDER>",
            "reason": map(field, error)
        }

    HTTP Status: 400 (in case of missing payload or part of it)
    Body: bad_request

Possibile reasons:

- auction_id: auction does not exist
- auction_id: auction is expired
- auction_id: auction is closed
- bid_value: below auction base
- bid_value: below highest bid

Note: if a valid blind auction id is passed, the call will fail by "auction does not exists" error

## Auction endpoinds

The auction is a "classic" auction, where the bidders are known and visible.

Base url: http://localhost:8081/api/v1/auctions

### Endpoints

Auctions list

    Method: GET
    Path: /
    Headers:
        Content-type: application/json
        Authorization: Bearer <TOKEN>

#### Successful response

    HTTP Status: 200

    %{
        "id" => ^auction_id,
        "auction_base" => 100,
        "expiration_date" => ^exp_str,
        "open" => true
    }

Auction creation

    Method: POST
    Path: /
    Headers:
        Content-type: application/json
        Authorization: Bearer <TOKEN>
    Body:
        {
            auction_base: <AUCTION_BASE>, (integer)
            expiration_date: "<EXPIRATION_DATE>", (ISO8601 bigger than `now`)
        }

#### Successful response:

    HTTP Status: 201

    Body
        {
            "auction_base":100,
            "auction_id":2,
            "expiration_date": "2021-05-25T03:54:09Z"
        }
    
If a user has subscribed to the auction, its client will receive a websocket message with the following payload:

    {
        notification_type: :bid, 
        auction_id: auction_id, 
        bid_value: bid_value
    }


#### Error responses:

    HTTP Status: 422
    Body
        {
            "reasons": [reasons]
        }
    
    HTTP Status: 400 (in case of missing payload or part of it)
    Body: bad_request

Possible reasons:

- auction_base must be positive
- expiry date must be bigger than creation date

Auction closing

    Method: POST
    Path: /close/:auction_id
    Headers:
        Content-type: application/json
        Authorization: Bearer <TOKEN>

#### Successful response

    HTTP Status: 200

## Bids endpoints

Base url: http://localhost:8081/api/v1/bids

### Endpoints

Bids list

    Method: GET
    Path: /:auction_id
    Headers:
        Authorization: Bearer <TOKEN>
    Body: none
    
#### Successful response:

    HTTP Status: 200

    Body
        [
            {"auction_id": 144, "bid_value": 10, "bidder": "some bidder"},
            {"auction_id": 144, "bid_value": 20, "bidder": "some bidder"},
            {"auction_id": 144, "bid_value": 30, "bidder": "some bidder"},
            {"auction_id": 144, "bid_value": 40, "bidder": "some bidder"},
            {"auction_id": 144, "bid_value": 50, "bidder": "some bidder"},
            {"auction_id": 144, "bid_value": 60, "bidder": "some bidder"},
            {"auction_id": 144, "bid_value": 70, "bidder": "some bidder"},
            {"auction_id": 144, "bid_value": 80, "bidder": "some bidder"},
            {"auction_id": 144, "bid_value": 90, "bidder": "some bidder"},
            {"auction_id": 144, "bid_value": 100, "bidder": "some bidder"}
        ]

Bids creation

    Method: POST
    Path: /
    Headers:
        Authorization: Bearer <TOKEN> 
        Content-Type: application/json
    Body:
        {
            "auction_id": <AUCTION_ID>, (integer)
            "bid_value": <BID>, (integer)
            "bidder": "<BIDDER>"
        }
    
#### Successful response:

    HTTP Status: 201

    Body:
        {
            "auction_id": <AUCTION_ID>, (integer)
            "bid_value": <BID>, (integer)
            "bidder": "<BIDDER>"
        }
      
#### Error response:

    HTTP Status: 422

    Body:
        {
            "auction_id": <AUCTION_ID>)
            "bid_value": <BID>,
            "bidder": "<BIDDER>",
            "reason": map(field, error)
        }

    HTTP Status: 400 (in case of missing payload or part of it)
    Body: bad_request

Possible map errors: 

- auction_id: auction does not exist
- auction_id: auction is expired
- auction_id: auction is closed
- bid_value: below auction base
- bid_value: below highest bid

Note: if a valid blind auction id is passed, the call will fail by "auction does not exists" error


## Blind auctions endpoints

We call `blind auctions` the auctions that give the chance to the user to make an offer for any artwork, not just
the ones auctioned.

Base url: `http://localhost:8082/api/v1/blind_auctions`

### Endpoints

Offer creation

    Method: POST
    Path: /
    Headers:
        Authorization: Bearer <TOKEN> 
        Content-Type: application/json
    Body:
        {
            "expiration_date": <expiration date> (ISO8601)
            "auction_base": auction_base (integer)
         }
    
#### Successful response:

    HTTP Status: 201

    Body:
        {
            auction_id: auction_id,
            auction_base: auction_base,
            expiration_date: expiration_date,
            open: true,
            blind: true
        }
      
#### Error response:

    Any non 200 status


# Curl commands

# Bids list
curl -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJFeEdhdGUiLCJleHAiOjE2MjE0MjQ3MTYsImlhdCI6MTYyMTQyMTExNiwiaXNzIjoiRXhHYXRlIiwianRpIjoiNDI4Nzc1ZjQtN2E5ZC00MWViLWIzYmYtMGQwNzg5YzU5ODZmIiwibmJmIjoxNjIxNDIxMTE1LCJzdWIiOiIxIiwidHlwIjoiYWNjZXNzIn0.-C7Op6cUNIe6KQwncZTNK1f3Kw-p_9LqAtq6UwZs5qLxqqxZZYGcWhJhxLYroqXEem9qD7oK6bmC4mJgkCRDlA" http://localhost:8081/api/v1/bids/1

# Auction creation

curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJFeEdhdGUiLCJleHAiOjE2MjE0MjQ3MTYsImlhdCI6MTYyMTQyMTExNiwiaXNzIjoiRXhHYXRlIiwianRpIjoiNDI4Nzc1ZjQtN2E5ZC00MWViLWIzYmYtMGQwNzg5YzU5ODZmIiwibmJmIjoxNjIxNDIxMTE1LCJzdWIiOiIxIiwidHlwIjoiYWNjZXNzIn0.-C7Op6cUNIe6KQwncZTNK1f3Kw-p_9LqAtq6UwZs5qLxqqxZZYGcWhJhxLYroqXEem9qD7oK6bmC4mJgkCRDlA" -d "{\"auction_base\":100,\"expiration_date\":\"2021-05-25 03:54:09.124103Z\"}" http://localhost:8081/api/v1/auctions/


# Bid creation

curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJFeEdhdGUiLCJleHAiOjE2MjE0MjQ3MTYsImlhdCI6MTYyMTQyMTExNiwiaXNzIjoiRXhHYXRlIiwianRpIjoiNDI4Nzc1ZjQtN2E5ZC00MWViLWIzYmYtMGQwNzg5YzU5ODZmIiwibmJmIjoxNjIxNDIxMTE1LCJzdWIiOiIxIiwidHlwIjoiYWNjZXNzIn0.-C7Op6cUNIe6KQwncZTNK1f3Kw-p_9LqAtq6UwZs5qLxqqxZZYGcWhJhxLYroqXEem9qD7oK6bmC4mJgkCRDlA" -d "{\"auction_id\":1, \"bid_value\":110,\"bidder\":\"bruno\"}" http://localhost:8081/api/v1/bids/
