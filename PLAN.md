# Plan

## Milestone 1 - MVP (ideally Wednesday, 19th)

- [x] Bruno: add this PLAN.md
- [x] Bruno: AuctionsProcess not needed anymore (we are leveraging DB as source of truth)
- [x] Bruno: add Postgres unique index on (auction_id, bid) for `bids` table
- [x] Bruno: `auctions` need to be serialized in the database and must have a duration field
- [x] Bruno: Add a `stop auction` emergency endpoint
- [x] Bruno: add endpoint documentation
- [x] Bruno: add `curl` example commands
- [x] Bruno: add websocket subscriptions
- [x] Bruno: created html login and auctions page
- [x] Bruno: add pagination and headers support
- [x] Bruno: update API doc with authorization information

## Milestone 2 - Correction of direction (distinction between blind auction and offers)

- [x]] Bruno: (OFFERS) ex_auction operates openly and can be applied to any artwork, effectively making every artwork a kind of "auction" automatically. For the moment no search will be used , the seed of the "browsing" is an artwork.
- [x] Bruno: (BLIND AUCTION) to implement a configuration by which the auction details are hidden (flag on the auction record).
- [x] This should be activated by an admin operator (the one who starts these auctions). 
- [x] The rest of the auction functionality MUST remain the same. 
- [ ] The auction details can be seen by an admin but not from the wide audience. 
- [x] The public user who accesses the auction information should see nothing except the expiry date and start date and the artwork for auction.
- [x] When it bids it can receive only the info that says the bid was successful or not (because it is smaller that the highest bid (without info on the amount of the highest bid)).
- [x] The websocket should only deliver an info when someone else outbids you.
- [ ] Andrea: (OFFERS) to implement accepting an offer. This must allow an owner to accept an offer and bind it to a specific address. Bruno: to track addesses of offerers. Bruno should handle identities triplets: google user_id (maybe with associated email), nickname in ex_auction (this could be collected once at login time), have an associated wallet address.

## MVP
