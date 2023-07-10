defmodule CaptainsLog do
  @planetary_classes ["D", "H", "J", "K", "L", "M", "N", "R", "T", "Y"]

  def random_planet_class() do
    Enum.random(@planetary_classes)
  end

  def random_ship_registry_number() do
    "NCC-#{Enum.random(1000..9999)}"
  end

  @doc "[41_000, 42_000)"
  def random_stardate() do
    41_000 + :rand.uniform() * 1000
  end

  def format_stardate(stardate) do
    stardate
    # |> Float.round(1)
    # &1 must be a float. otherwise it will throw error
    |> then(&:io_lib.format("~.1f", [&1]))
    |> to_string
  end
end
