ex_auction
----------


an off-chain and on-chain auction service


## Requirements

- It **MUST** support real time notification (e.g. via websockets) to inform every connected bidder that a new highest bid was placed
- It **MUST** support placing bids (i.e. write to the state) only via revokable authentication. One way to achieve this is to have a REST endpoint protected via oauth2 (e.g. guardian library).
- It **MUST** support google oauth2
- It **SHOULD** support facebook, twitter, linkedin oauth2
- It **COULD** support other type of oauth2 (to be discussed)
- It **MUST** support a persistent and authoritative state for clearance to place bids. This **SHOULD** contain some KYC information and **MUST** contain a custodian balance that can be reclaimed only if the auction was unsuccessful. It will be lost if the customer is the highest bidder but fails to purchase the actual artwork.
