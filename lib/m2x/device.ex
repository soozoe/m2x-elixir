defmodule M2X.Device do
  @moduledoc """
    Wrapper for the AT&T M2X <a href="https://m2x.att.com/developer/documentation/v2/device"> Device API </a>
  """
  use M2X.Resource, path: {"/devices", :id}

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#View-Device-Details">View Device Details</a> endpoint.

    Retrieve a view of the Device associated with the given unique id.

    - client: M2X.Client struct
    - id: ID of the Device to retrieve
    - Returns: The matching Device
  """
  def fetch(client = %M2X.Client{}, id) do
    case M2X.Client.get(client, path(id)) do
      {:ok, res} -> {:ok, %M2X.Device { client: client, attrs: res.json }}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#List-Devices">List Devices</a> endpoint.

    Retrieve the list of Devices accessible by the authenticated API key.

    - client: M2X.Client struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters.
    - Returns: List of Devices
  """
  def list(client = %M2X.Client{}, params\\nil) do
    case M2X.Client.get(client, @main_path, params) do
      {:ok, res} ->
        list = Enum.map res.json["devices"], fn (attrs) ->
          %M2X.Device { client: client, attrs: attrs }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Search-Devices">Search Devices</a> endpoint.

    Retrieve the list of Devices accessible by the authenticated API key that
    meet the search criteria.

    - client: M2X.Client struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters.
    - Returns: List of Devices
  """
  def search(client = %M2X.Client{}, params\\nil) do
    case M2X.Client.get(client, @main_path<>"/search", params) do
      {:ok, res} ->
        list = Enum.map res.json["devices"], fn (attrs) ->
          %M2X.Device { client: client, attrs: attrs }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#List-Public-Devices-Catalog">List/Search Public Devices Catalog</a> endpoint.

    This allows unauthenticated users to search Devices from other users
    that have been marked as public, allowing them to read public Device
    metadata, locations, streams list, and view each Devices' stream metadata
    and its values.

    - client: M2X.Client struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters.
    - Returns: List of Devices
  """
  def catalog(client = %M2X.Client{}, params\\nil) do
    case M2X.Client.get(client, @main_path<>"/catalog", params) do
      {:ok, res} ->
        list = Enum.map res.json["devices"], fn (attrs) ->
          %M2X.Device { client: client, attrs: attrs }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Read-Device-Location">Read Device Location</a> endpoint.

    Get location details of an existing Device.
    Note that this method can return an empty value (response status
    of 204) if the device has no location defined.

    - device: M2X.Device struct
    - Returns: Most recently logged location of the Device, see M2X API docs for details
  """
  def get_location(device = %M2X.Device { client: client }) do
    M2X.Client.get(client, path(device)<>"/location")
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Read-Device-Location-History">Read Device Location History</a> endpoint.

    Get location history details of an existing Device.

    - device: M2X.Device struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: Location history of the Device
  """
  def location_history(device = %M2X.Device { client: client }, params\\%{}) do
    M2X.Client.get(client, path(device)<>"/location/waypoints", params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Update-Device-Location">Update Device Location</a> endpoint.

    Update the current location of the specified device.

    - device: M2X.Device struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: The API response, see M2X API docs for details
  """
  def update_location(device = %M2X.Device { client: client }, params) do
    M2X.Client.put(client, path(device)<>"/location", params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Delete-Location-History">Delete Location History</a> endpoint.

    Delete location history of the specified device.

    - device: M2X.Device struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: The API response, see M2X API docs for details
  """
  def delete_location_history(device = %M2X.Device { client: client }, params) do
    M2X.Client.delete(client, path(device)<>"/location/waypoints", params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Read-Device-Metadata">Read Device Metadata</a> endpoint.

    Get the custom metadata for the specified Device.

    - device: M2X.Device struct
    - Returns: User defined metadata associated with the device
  """
  def metadata(device = %M2X.Device { client: client }) do
    M2X.Client.get(client, path(device)<>"/metadata")
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Update-Device-Metadata">Update Device Metadata</a> endpoint.

    Update the custom metadata for the specified Device.

    - device: M2X.Device struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: The API response, see M2X API docs for details
  """
  def update_metadata(device = %M2X.Device { client: client }, params) do
    M2X.Client.put(client, path(device)<>"/metadata", params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Read-Device-Metadata-Field">Read Device Metadata Field</a> endpoint.

    Get the custom metadata for the specified Device.

    - device: M2X.Device struct
    - name: The metadata field to be read
    - Returns: The API response, see M2X API docs for details
  """
  def get_metadata_field(device = %M2X.Device { client: client }, name) do
    M2X.Client.get(client, path(device)<>"/metadata/"<>name)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Update-Device-Metadata-Field">Update Device Metadata Field</a> endpoint.

    Update the custom metadata field for the specified Device.

    - device: M2X.Device struct
    - name: The metadata field to be updated
    - value: The value to update
    - Returns: The API response, see M2X API docs for details
  """
  def set_metadata_field(device = %M2X.Device { client: client }, name, value) do
    M2X.Client.put(client, path(device)<>"/metadata/"<>name, %{ "value" => value })
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#List-Values-from-all-Data-Streams-of-a-Device">List Values from all Data Streams of a Device</a> endpoint.

    - device: M2X.Device struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: The API response, see M2X API docs for details
  """
  def values(device = %M2X.Device { client: client }, params) do
    M2X.Client.get(client, path(device)<>"/values", params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Search-Values-from-all-Data-Streams-of-a-Device">Search Values from all Data Streams of a Device</a> endpoint.

    - device: M2X.Device struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: The API response, see M2X API docs for details
  """
  def values_search(device = %M2X.Device { client: client }, params) do
    M2X.Client.get(client, path(device)<>"/values/search", params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Export-Values-from-all-Data-Streams-of-a-Device">Export Values from all Data Streams of a Device</a> endpoint.

    - device: M2X.Device struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: The API response, see M2X API docs for details
  """
  def values_export_csv(device = %M2X.Device { client: client }, params\\%{}) do
    M2X.Client.get(client, path(device)<>"/values/export.csv", params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Post-Device-Update--Single-Values-to-Multiple-Streams-">Post Device Update (Single Values to Multiple Streams)</a> endpoint.

    This method allows posting single values to multiple streams.

    - device: M2X.Device struct
    - params: The values being posted, formatted according to the API docs
    - Returns: The API response, see M2X API docs for details
  """
  def post_update(device = %M2X.Device { client: client }, params) do
    M2X.Client.post(client, path(device)<>"/update", params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Post-Device-Updates--Multiple-Values-to-Multiple-Streams-">Post Device Update (Multiple Values to Multiple Streams)</a> endpoint.

    This method allows posting multiple values to multiple streams
    belonging to a device and optionally, the device location.

    - device: M2X.Device struct
    - params: The values being posted, formatted according to the API docs
    - Returns: The API response, see M2X API docs for details
  """
  def post_updates(device = %M2X.Device { client: client }, params) do
    M2X.Client.post(client, path(device)<>"/updates", params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#List-Data-Streams">List Data Streams</a> endpoint.

    Retrieve list of Streams associated with the specified Device.

    - device: M2X.Device struct
    - Returns: List of data streams associated with this device as Stream objects
  """
  def streams(device = %M2X.Device { client: client }) do
    case M2X.Client.get(client, path(device)<>"/streams") do
      {:ok, res} ->
        list = Enum.map res.json["streams"], fn (attrs) ->
          %M2X.Stream { client: client, attrs: attrs, under: path(device) }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#View-Data-Stream">View Data Stream</a> endpoint.

    Get details of a specific Stream associated with the Device.

    - device: M2X.Device struct
    - name: The name of the Stream being retrieved
    - Returns: The matching Stream
  """
  def stream(device = %M2X.Device { client: client }, name) do
    M2X.Stream.refreshed %M2X.Stream {
      client: client, under: path(device), attrs: %{ "name"=>name }
    }
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Create-Update-Data-Stream">Create/Update Data Stream</a> endpoint.

    Update a Stream associated with the Device with the given parameters.
    If a Stream with this name does not exist it will be created.

    - device: M2X.Device struct
    - name: Name of the stream to be updated
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: The Stream being updated
  """
  def update_stream(device = %M2X.Device { client: client }, name, params) do
    M2X.Stream.update! %M2X.Stream {
      client: client, under: path(device), attrs: %{ "name"=>name }
    }, params
  end
  def create_stream(a,b,c) do update_stream(a,b,c) end # Alias

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/commands#Device-s-List-of-Received-Commands">Device's List of Received Commands</a> endpoint.

    Retrieve the list of recent commands sent to the Device.

    - device: M2X.Device struct
    - Returns: The API response, see M2X API docs for details
  """
  def commands(device = %M2X.Device { client: client }) do
    case M2X.Client.get(client, path(device)<>"/commands") do
      {:ok, res} ->
        list = Enum.map res.json["commands"], fn (attrs) ->
          %M2X.Command { client: client, attrs: attrs }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/commands#Device-s-View-of-Command-Details">Device's View of Command Details</a> endpoint.

    Get details of a received command for this Device.

    - device: M2X.Device struct
    - command_id: ID of the Command to retrieve
    - Returns: The API response, see M2X API docs for details
  """
  def command(device = %M2X.Device { client: client }, command_id) do
    case M2X.Client.get(client, path(device)<>"/commands/"<>command_id) do
      {:ok, res} -> {:ok, %M2X.Command { client: client, attrs: res.json }}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/commands#Device-Marks-a-Command-as-Processed">Device Marks a Command as Processed</a> endpoint.
    Mark the given command as processed by this Device.

    - device: M2X.Device struct
    - id: ID of the Command being marked as processed
    - Returns: The API response, see M2X API docs for details
  """
  def process_command(device = %M2X.Device { client: client },
                      %M2X.Command { attrs: %{ "id" => command_id } },
                      params\\%{}) do
    req_path = path(device)<>"/commands/"<>command_id<>"/process"
    M2X.Client.post(client, req_path, params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/commands#Device-Marks-a-Command-as-Rejected">Device Marks a Command as Rejected</a> endpoint.

    Mark the given command as rejected by this Device.

    - device: M2X.Device struct
    - id: ID of the Command being marked as rejected
    - Returns: The API response, see M2X API docs for details
  """
  def reject_command(device = %M2X.Device { client: client },
                     %M2X.Command { attrs: %{ "id" => command_id } },
                     params\\%{}) do
    req_path = path(device)<>"/commands/"<>command_id<>"/reject"
    M2X.Client.post(client, req_path, params)
  end

end
