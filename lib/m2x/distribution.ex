defmodule M2X.Distribution do
  @moduledoc """
    Wrapper for the AT&T M2X <a href="https://m2x.att.com/developer/documentation/v2/distribution"> Distribution API </a>
  """
  use M2X.Resource, path: {"/distributions", :id}

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/distribution#View-Distribution-Details">View Distribution Details</a> endpoint.
    Retrieve a view of the Distribution associated with the given unique id.

    - client: M2X.Client struct
    - id: ID of the Distribution to retrieve
    - Returns: The matching Distribution
  """
  def fetch(client = %M2X.Client{}, id) do
    case M2X.Client.get(client, path(id)) do
      {:ok, res} -> {:ok, %M2X.Distribution { client: client, attrs: res.json }}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/distribution#Read-Distribution-Metadata">Read Distribution Metadata</a> endpoint.
    Get the custom metadata for the specified Distribution.

    - dist: M2X.Distribution struct
    - Returns: User defined metadata associated with the distribution
  """
  def metadata(dist = %M2X.Distribution { client: client }) do
    M2X.Client.get(client, path(dist)<>"/metadata")
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/distribution#Update-Distribution-Metadata">Update Distribution Metadata</a> endpoint.
    Update the custom metadata for the specified Distribution.

    - dist: M2X.Distribution struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: The API response, see M2X API docs for details
  """
  def update_metadata(dist = %M2X.Distribution { client: client }, params) do
    M2X.Client.put(client, path(dist)<>"/metadata", params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/distribution#Update-Distribution-Metadata">Read Distribution Metadata Field</a> endpoint.
    Get the custom metadata for the specified Distribution.

    - dist: M2X.Distribution struct
    - name: The metadata field to be read
    - Returns: The API response, see M2X API docs for details

  """
  def get_metadata_field(dist = %M2X.Distribution { client: client }, name) do
    M2X.Client.get(client, path(dist)<>"/metadata/"<>name)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/distribution#Update-Distribution-Metadata-Field">Update Distribution Metadata Field</a> endpoint.
    Update the custom metadata for the specified Distribution.

    - dist: M2X.Distribution struct
    - name: The metadata field to be updated
    - value: The value to update
    - Returns: The API response, see M2X API docs for details
  """
  def set_metadata_field(dist = %M2X.Distribution { client: client }, name, value) do
    M2X.Client.put(client, path(dist)<>"/metadata/"<>name, %{ "value" => value })
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/distribution#List-Distributions">List Distributions</a> endpoint.

    Retrieve the list of Distributions accessible by the authenticated API key
    that meet the search criteria.

    - client: M2X.Client struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: List of Device Distributions

  """
  def list(client = %M2X.Client{}, params\\nil) do
    case M2X.Client.get(client, @main_path, params) do
      {:ok, res} ->
        list = Enum.map res.json["distributions"], fn (attrs) ->
          %M2X.Distribution { client: client, attrs: attrs }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/distribution#List-Devices-from-an-existing-Distribution">List Devices from an existing Distribution</a> endpoint.

    Retrieve list of Devices added to the specified Distribution.

    - dist: M2X.Distribution struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: List of Devices associated with this Distribution
  """
  def devices(dist = %M2X.Distribution{ client: client }, params\\nil) do
    case M2X.Client.get(client, path(dist)<>"/devices", params) do
      {:ok, res} ->
        list = Enum.map res.json["devices"], fn (attrs) ->
          %M2X.Device { client: client, attrs: attrs }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/distribution#Add-Device-to-an-existing-Distribution">Add Device to an existing Distribution</a> endpoint.

    Add a new Device to the Distribution, with the given unique serial string.

    - dist: M2X.Distribution struct
    - serial: The unique (account-wide) serial for the DistributionDevice being added to the Distribution
    - Returns: The newly created DistributionDevice
  """
  def add_device(dist = %M2X.Distribution{ client: client }, serial) do
    params = %{ serial: serial }
    case M2X.Client.post(client, path(dist)<>"/devices", params) do
      {:ok, res} -> {:ok, %M2X.Device { client: client, attrs: res.json }}
      error_pair -> error_pair
    end
  end

end
