# Plan

## Milestone 1 - MVP (ideally Wednesday, 19th)

- [x] Bruno: add this PLAN.md
- [x] Bruno: AuctionsProcess not needed anymore (we are leveraging DB as source of truth)
- [x] Bruno: add Postgres unique index on (auction_id, bid) for `bids` table
- [x] Bruno: `auctions` need to be serialized in the database and must have a duration field
- [ ] Bruno: Add a `stop auction` emergency endpoint
- [x] Bruno: add endpoint documentation
- [ ] Bruno: add `curl` example commands
- [x] Bruno: add websocket subscriptions
