import Config

# ** default routing table
config :kv, :routing_table, [{?a..?z, node()}]

# ** set actual routing table for prod
if config_env() == :prod do
  config :kv, :routing_table, [
    {?a..?m, :"a@Krikchais-MacBook-Pro-M1"},
    {?n..?z, :"b@Krikchais-MacBook-Pro-M1"}
  ]
end
