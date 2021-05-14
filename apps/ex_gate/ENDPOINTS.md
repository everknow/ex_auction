## ENDPOINTS

### Bidding

    PATH: /api/bid
    HEADERS: 
        Content-Type: "application/json"
        Authorization: "Bearer TOKEN"
    BODY: {"bid":"value"}

    RESPONSES:
        Success: {"bid": "success"}
        Failure: {"bid": "failure"}

The `TOKEN` must be created client side by implementing the Google OAuth2 authentication procedure, and it's mandatory to access the endpoint.

[Back](README.md) to docs.