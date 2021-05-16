# ExAuctionsManager

This application implements the auctions logic.

## Design

For each open auction, a process is spawned; after that, the status of the bid is rebuilt (read: the latest bid here represents the status of the bid). In this condition, the process is able to accept bids:

    {:bid, <bid_value>, <bidder>}

if the proposed bid is _bigger_ than the current one (the status of the auction) the bid is accepted:

    {:accepted, <bid_value>}
  
otherwise, it's rejected:

    {:rejected, <bid_value>, <latest_bid>}

## Endpoints

### Bids list

The bid list endpoint is:

    PATH: /api/v1/bids/<auction_id>
    VERB: GET
    HEADERS: 
      Content-Type: application/json
      Authorization: Bearer <TOKEN>
    BODY: None

### Bid creation

To be done
