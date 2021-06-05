# ExAuction - Umbrella application

## Login

Client needs to authenticate the user against Google, he receives a token and must
pass it to the endpoint:

    /api/v1/login

with body:

    {
        id_token: ID_TOKEN
    }

If the token is verified the user will be registered and an access_token will be provided to the client. That access token is the one to be used to authenticate every protected api call.

Response:

    {
        "access_token" => token,
        "token_type" => "Bearer",
        # Shouldn't the expire come from the Guardian job ?
        "expires_in" => 3600
        # "refresh_token": ??
    }

In case of error, you have 401 if the token is not valid, or 404 is the user does not exist. In that case, client has to call the _registration_ endpoint:

## Registration


Client needs to authenticate the user against Google, he receives a token and must
pass it to the endpoint:

    /api/v1/register

with body:

    {
        id_token: ID_TOKEN,
        username: USERNAME
    }

If the token is verified and the username is not yet used, a new registration will happen and you will receive the following response:

    {
        "access_token" => token,
        "token_type" => "Bearer",
        # Shouldn't the expire come from the Guardian job ?
        "expires_in" => 3600
        # "refresh_token": ??
    }

If the token is invalid, client will receive a 401, or if the user email (deduced from the token) / username is already taken, a 422 will be returned.


## Websocket

When the user is authenticated, the client can open a websocket contacting

    ws://localhost:8080/ws (should be wss in production) 

upon connection, it needs to send a message to bind the username to the websocket for future 
communication needs.

    {
        user_identification: user_id
    }

Respose: `user identification received`

### Auction subscription

To subscribe an user to a specific auction, ssend the payload:

    {
        subscribe: auction_id
    };

Response: `subscribed`

