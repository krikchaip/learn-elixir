# Official Guides Project (`KV` & `KVServer`)

## Development

Single Mode

```bash
$ iex -S mix
```

Distributed Mode

```bash
$ iex --sname a -S mix
$ iex --sname b -S mix
```

## Testing

Run without `:distributed` tests

```bash
$ mix test
```

Only with `:distributed` tag

```bash
$ iex --sname b -S mix run &
$ elixir --sname a -S mix test --only distributed
```

## Build for production

```bash
$ MIX_ENV=prod mix release a
$ MIX_ENV=prod mix release b
```

## Playing around

```bash
# start 2 nodes simultaneously
$ _build/prod/rel/a/bin/a start
$ _build/prod/rel/b/bin/b start

...

# execute this in another shell
$ nc localhost 4040

CREATE winner
# OK
EIEI
# UNKNOWN COMMAND
PUT winner age 99
# OK
GET winner age
# 99
# OK
DELETE winner age
# OK
```
