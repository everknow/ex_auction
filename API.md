# API

## Auctions api

Base url: `http://localhost:8081/api/v1/auctions`

### Endpoints

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

Successful response:

    HTTP Status: 201

    Body
        {
            "auction_base":100,
            "auction_id":2,
            "expiration_date": "2021-05-25T03:54:09Z"
        }

Error responses:

    HTTP Status: 422
    Body
        {
            "reasons": [
                "expiry date must be bigger than creation date"
            ]
        }
    
    HTTP Status: 400 (in case of missing payload or part of it)
    Body: bad_request



## Bids api

Base url: `http://localhost:8081/api/v1/bids`

### Endpoints

Bids list

    Method: GET
    Path: /:auction_id
    Headers:
        Authorization: Bearer <TOKEN>
    Body: none
    
Successful response:

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
    
Successful response:

    HTTP Status: 201

    Body:
        {
            "auction_id": <AUCTION_ID>, (integer)
            "bid_value": <BID>, (integer)
            "bidder": "<BIDDER>"
        }
      
Error response:

    HTTP Status: 422

    Body:
        {
            "auction_id": <AUCTION_ID>)
            "bid_value": <BID>,
            "bidder": "<BIDDER>",
            "reason": ["auction does not exist"]
        }

    HTTP Status: 400 (in case of missing payload or part of it)
    Body: bad_request
    
# Curl commands

The above endpoints can be used with the following curl commands:


# Bids list
curl -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJFeEdhdGUiLCJleHAiOjE2MjE0MjQ3MTYsImlhdCI6MTYyMTQyMTExNiwiaXNzIjoiRXhHYXRlIiwianRpIjoiNDI4Nzc1ZjQtN2E5ZC00MWViLWIzYmYtMGQwNzg5YzU5ODZmIiwibmJmIjoxNjIxNDIxMTE1LCJzdWIiOiIxIiwidHlwIjoiYWNjZXNzIn0.-C7Op6cUNIe6KQwncZTNK1f3Kw-p_9LqAtq6UwZs5qLxqqxZZYGcWhJhxLYroqXEem9qD7oK6bmC4mJgkCRDlA" http://localhost:8081/api/v1/bids/1

# Auction creation

curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJFeEdhdGUiLCJleHAiOjE2MjE0MjQ3MTYsImlhdCI6MTYyMTQyMTExNiwiaXNzIjoiRXhHYXRlIiwianRpIjoiNDI4Nzc1ZjQtN2E5ZC00MWViLWIzYmYtMGQwNzg5YzU5ODZmIiwibmJmIjoxNjIxNDIxMTE1LCJzdWIiOiIxIiwidHlwIjoiYWNjZXNzIn0.-C7Op6cUNIe6KQwncZTNK1f3Kw-p_9LqAtq6UwZs5qLxqqxZZYGcWhJhxLYroqXEem9qD7oK6bmC4mJgkCRDlA" -d "{\"auction_base\":100,\"expiration_date\":\"2021-05-25 03:54:09.124103Z\"}" http://localhost:8081/api/v1/auctions/


# Bid creation

curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJFeEdhdGUiLCJleHAiOjE2MjE0MjQ3MTYsImlhdCI6MTYyMTQyMTExNiwiaXNzIjoiRXhHYXRlIiwianRpIjoiNDI4Nzc1ZjQtN2E5ZC00MWViLWIzYmYtMGQwNzg5YzU5ODZmIiwibmJmIjoxNjIxNDIxMTE1LCJzdWIiOiIxIiwidHlwIjoiYWNjZXNzIn0.-C7Op6cUNIe6KQwncZTNK1f3Kw-p_9LqAtq6UwZs5qLxqqxZZYGcWhJhxLYroqXEem9qD7oK6bmC4mJgkCRDlA" -d "{\"auction_id\":1, \"bid_value\":110,\"bidder\":\"bruno\"}" http://localhost:8081/api/v1/bids/

Of course tokens and values must be changed accordingly.