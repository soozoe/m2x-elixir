defmodule DeleteLocationHistoryExample do
  @moduledoc """
    This example demonstrates how to delete location history for a device

    API Documentation:
    https://m2x.att.com/developer/documentation/v2/device#Delete-Location-History

    Setup:
    Replace <M2X-API-KEY> with an M2X API Key
    Replace <M2X-DEVICE-ID> with a device id
  """

  import M2X

  params = %{ :from => "2015-01-01T01:00:00.000Z", :end => "2016-01-01T01:00:00.000Z" }

  client = %M2X.Client { api_key: "<M2X-API-KEY>" }
  {:ok, device} = M2X.Device.fetch(client, "<M2X-DEVICE-ID>")

  {:ok, res} = M2X.Device.delete_location_history(device, params)

  IO.puts res.status

end
