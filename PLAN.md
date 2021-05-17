# Plan

## Milestone 1 - MVP (ideally Wednesday, 19th)

    [ ] Bruno: AuctionsProcess not needed anymore (we are leveraging DB as source of truth)
    [ ] Bruno: add Postgres unique index on (auction_id, bid) for `bids` table
    [ ] Bruno: `auctions` need to be serialized in the database and must have a duration field
    [ ] Bruno: Add a `stop auction` emergency endpoint
    [ ] Bruno: add endpoint documentation with `curl` example commands and response examples