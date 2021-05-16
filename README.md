# ExAuction - Umbrella application

The app is made of several components:

1. Auctions manager (name: [ExAuctionsManager](apps/ex_auctions_manager/README.md)). It's resposible to implement the auction logic, exposing proper endpoints.
2. Gate: (name: [ExGate](apps/ex_gate/README.md)). It's responsible to handle authentication and token generation to access all the other endpoints.

