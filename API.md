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

Error response:

    HTTP Status: 500
    Body
        {
            "reasons": [
                "expiry date must be bigger than creation date"
            ]
        }



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

    HTTP Status: 500 (Maybe a 404 ?)

    Body:
        {
            "auction_id": <AUCTION_ID>)
            "bid_value": <BID>,
            "bidder": "<BIDDER>",
            "reason": ["auction does not exist"]
        }
