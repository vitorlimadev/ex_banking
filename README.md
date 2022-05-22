# ExBanking

A banking application that handles multiple currencies using pure Elixir and the OTP.
Currencies are floating point numbers with two decimal precision.

The application creates GenServers for each user to handle their state.
A user's GenServer can only have at maximum 10 transaction messages at any time.
