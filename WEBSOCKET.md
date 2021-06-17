# Websocket implementation

The client must connect to the wss server by opening a socket at `wss://api.reasonedart.com/ws/`.

Once the channel is open, the client must present the user, sending a message with the authorization token in the body.

## Valid messages

List of all the messages that the client can send and when:

### Auction subscription

An user decides to "watch" an auction, so the client must send the following message:

{
    token: <authorization_token>,
    type: "subscribe_to_auction",
    data: {
        auction_id: <auction_id>
    }
}

Successful response:
    {
        status: "ok"
    }

Error response: 

    {
        status: "error",
        data: {
            error: <error>,
            message: ""  # This is to be verified, might be redundant
        }
    }



## Notifications

List of all the notifications that the client can receive and their meaning:

### Blind Auction Outbid

    {
        message: "user has been outbid"
    }

### Auction Outbid


    {
        message: "user has been outbid",
        data: {
            bidder: <bidder_username>,
            auction_id: <auction_id>,
            bid_value: <bid_value>
        }
    }

## Technical implementation

Upon user presentation, the socket process must be stored. This will be the entry point to understand how to communicate with a given user.

For a given user, the following information could be available:

- the `id` of one or more blind auctions he's successfully bidding on
- the `id` of one or more auctions he has put in the watch list

Note: while the former type of information can be deduced from the database when the user gets presented by the client, the latter cannot be deduced and to make them consistent between logins they must be persisted.
