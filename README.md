# EctoTypes

A small collection of types I've reused across more than one project.

### Token

A simple token that can be used in a url as a surrogate key.  Includes a 10-bit checksum
to avoid even querying the database if invalid.  Stored in the database as a native UUID field 
for query/index performance and overall reduction in storage space.

### U.S. Phone Number

Handles the phone number format used in the United States and Canada.  Expects input as a binary
but stores data as a bigint for query/index performance and overall reduction in storage space.

### U.S. Postal Code

Soon.

## Installation

Not currently available via `hex` but accessible through github by adding `ecto_types` to your 
list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_types, "~> 0.1.0", github: "atavistock/ecto_types"}
  ]
end
```
