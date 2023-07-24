defmodule OfficialGuides.MixProject do
  use Mix.Project

  def project do
    [
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # ** umbrella specific configs
      apps_path: "apps",
      releases: releases()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    []
  end

  def releases do
    [
      # ** deploy all applications in the umbrella to a node
      # ** that will work as both TCP server and key-value storage
      # monolith: [
      #   applications: [kv: :permanent, kv_server: :permanent]
      # ],

      # ** set the cookie option on both releases to the same value
      # ** in order for them to allow connections from each other
      a: [
        cookie: "weknoweachother",
        applications: [kv_server: :permanent, kv: :permanent]
      ],
      b: [
        cookie: "weknoweachother",
        applications: [kv: :permanent]
      ]
    ]
  end
end
