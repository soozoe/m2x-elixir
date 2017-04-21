defmodule M2X.Collection do
  @moduledoc """
    Wrapper for the AT&T M2X <a href="https://m2x.att.com/developer/documentation/v2/collections"> Collection API </a>
  """
  use M2X.Resource, path: {"/collections", :id}

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/collections#View-Collection-Details">View Collection Details</a> endpoint.

    Retrieve a view of the Collection associated with the given unique id.

    - client: M2X.Client struct
    - id: ID of the Collection to retrieve
    - Returns: The matching Collection
  """
  def fetch(client = %M2X.Client{}, id) do
    case M2X.Client.get(client, path(id)) do
      {:ok, res} -> {:ok, %M2X.Collection { client: client, attrs: res.json }}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/collections#Read-Collection-Metadata">Read Collection Metadata</a> endpoint.

    Get the custom metadata for the specified Collection.

    - coll: M2X.Collection struct
    - Returns: User defined metadata associated with the collection
  """
  def metadata(coll = %M2X.Collection { client: client }) do
    M2X.Client.get(client, path(coll)<>"/metadata")
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/collections#Update-Collection-Metadata">Update Collection Metadata</a> endpoint.

    Update the custom metadata for the specified Collection.

    - coll: M2X.Collection struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: The API response, see M2X API docs for details
  """
  def update_metadata(coll = %M2X.Collection { client: client }, params) do
    M2X.Client.put(client, path(coll)<>"/metadata", params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/collections#Read-Collection-Metadata-Field">Read Collection Metadata Field</a> endpoint.

    Get the custom metadata for the specified Collection.

    - coll: M2X.Collection struct
    - name: The metadata field to be read
    - Returns: The API response, see M2X API docs for details
  """
  def get_metadata_field(coll = %M2X.Collection { client: client }, name) do
    M2X.Client.get(client, path(coll)<>"/metadata/"<>name)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/collections#Update-Collection-Metadata-Field">Update Collection Metadata Field</a> endpoint.

    Update the custom metadata for the specified Collection.

    - coll: M2X.Collection struct
    - name: The metadata field to be updated
    - value: The value to update
    - Returns: The API response, see M2X API docs for details
  """
  def set_metadata_field(coll = %M2X.Collection { client: client }, name, value) do
    M2X.Client.put(client, path(coll)<>"/metadata/"<>name, %{ "value" => value })
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/collections#List-collections">List collections</a> endpoint.

    Retrieve the list of Collections accessible by the authenticated API key
    that meet the search criteria.

    - client: M2X.Client struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: List of Device Distributions
  """
  def list(client = %M2X.Client{}, params\\nil) do
    case M2X.Client.get(client, @main_path, params) do
      {:ok, res} ->
        list = Enum.map res.json["collections"], fn (attrs) ->
          %M2X.Collection { client: client, attrs: attrs }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/collections#Add-device-to-collection">Add device to collection</a> endpoint.

    Add device to specified Collection.

    - coll: M2X.Collection struct
    - device_id: ID of the Device being added to Collection
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: The API response, see M2X API docs for details
  """
  def add_device(coll = %M2X.Collection { client: client }, device_id, params) do
    M2X.Client.put(client, path(coll)<>"/devices/"<>device_id, params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/collections#Remove-device-from-collection">Remove device from collection</a> endpoint.

    Remove device from secified Collection.

    - coll: M2X.Collection struct
    - device_id: ID of the Device being removed from Collection
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: The API response, see M2X API docs for details
  """
  def remove_device(coll = %M2X.Collection { client: client }, device_id, params) do
    M2X.Client.delete(client, path(coll)<>"/devices/"<>device_id, params)
  end

end
