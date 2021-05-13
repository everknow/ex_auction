## Requirements

- It **MUST** support real time notification (e.g. via websockets) to inform every connected bidder that a new highest bid was placed
- It **MUST** support placing bids (i.e. write to the state) only via revokable authentication. One way to achieve this is to have a REST endpoint protected via oauth2 (e.g. guardian library).
- It **MUST** support google oauth2
- It **SHOULD** support facebook, twitter, linkedin oauth2
- It **COULD** support other type of oauth2 (to be discussed)
- It **MUST** support a persistent and authoritative state for clearance to place bids. This **SHOULD** contain some KYC information and **MUST** contain a custodian balance that can be reclaimed only if the auction was unsuccessful. It will be lost if the customer is the highest bidder but fails to purchase the actual artwork.
- It **MUST** support the purchase on chain of the won artwork. The purchase is not necessarily requiring a financial settlement on chain. We can accept bank transfers as a form of payment, in this case we just operate a transfer of the token paying the gas fee on chain, but not the full balance of the artwork.
- It **MUST** support an internal state that drives the logic of the auction (this should be ovious)
- It **MUST** expose a documented API for the UI to be attached
- It **MUST** support a persistent and managed data store (eg. Postgres on GCP).
- The DB **MUST** contain all the custodian information for automating as much as possible the process of handlig the financials surrounding the auction.
- The DB **SHOULD** store the BID history so that an ephemeral state of an aouction can be restored if necessary.
- It **MUST** support deployment scripts for any kubernetes and cloud services to be deployed on demand by specifying the type of environment (dev,prod ..etc..)
- It **MUST** support a CI via github actions. (We **MUST** have a separate trigger for type spec check and code formatting).

[Back](README.md) to docs.