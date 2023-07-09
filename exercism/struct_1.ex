defmodule RemoteControlCar do
  @enforce_keys [:nickname]
  defstruct [:nickname, battery_percentage: 100, distance_driven_in_meters: 0]

  def new(nickname \\ "none"), do: %__MODULE__{nickname: nickname}

  def display_distance(%__MODULE__{distance_driven_in_meters: d}) do
    "#{d} meters"
  end

  def display_battery(%__MODULE__{battery_percentage: b}) do
    "Battery #{if b > 0, do: "at #{b}%", else: "empty"}"
  end

  def drive(%__MODULE__{distance_driven_in_meters: d, battery_percentage: b} = car) do
    {d, b} = if b > 0, do: {d + 20, b - 1}, else: {d, b}
    %{car | distance_driven_in_meters: d, battery_percentage: b}
  end
end
