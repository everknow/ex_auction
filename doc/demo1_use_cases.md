UC1
---

- Create an auction via an `admin` endpoint with `expiry time` (10 minutes)  and `minimum price` (100)
- Bidder 1 joins and subscribes to the auction
- Bidder 1 places a bid of 90 => failure for insufficient amount
- Bidder 2 joins and subscribes to the auction
- Bidder 1 places a bid of 120 => success + multicast notifications (show it came through the WS)
- Bidder 2 places a bid of 110 => failure for insufficient amount
- Bidder 2 places a bid of 130 => success + multicast notifications (show it came through the WS)
- Bidder 3 joins and subscribes to the auction
- Bidder 3 fetches the page of history, sees the two successful bids
- Bidder 1 places a bid of 150 => success + multicast notifications (show it came through the WS)
- Auction closes => multicast notifications (show it came through the WS)
- Bidder 3 places a bid of 160 => failure for auction closed
