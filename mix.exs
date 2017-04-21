defmodule M2X.Mixfile do
  use Mix.Project

  def version, do: "2.0.0" # Version number must also be updated in client.ex

  def project do
    [ app:         :m2x,
      version:     version,
      elixir:      "~> 1.0",
      deps:        dependencies,
      description: description,
      package:     package ]
  end

  def application do [] end

  defp dependencies do
    [ {:hackney, "~> 1.0"},
      {:json,    "~> 0.3"},
      {:earmark, "~> 0.1",  only: :dev, runtime: false},
      {:ex_doc,  "~> 0.11", only: :dev, runtime: false} ]
  end

  defp description do
    """
    Elixir client library for the AT&T M2X (http://m2x.att.com) API.
    AT&T M2X is a cloud-based fully managed time-series data storage service
    for network connected machine-to-machine (M2M) devices and the
    Internet of Things (IoT).
    """
  end

  defp package do
    [ maintainers: ["Joe McIlvain"],
      licenses:    ["MIT"],
      links: %{
        "GitHub"   => "https://github.com/attm2x/m2x-elixir",
        "API Docs" => "https://m2x.att.com/developer/documentation"
      } ]
  end
end
