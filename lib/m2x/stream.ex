defmodule M2X.Stream do
  @moduledoc """
    Wrapper for the AT&T M2X <a href="https://m2x.att.com/developer/documentation/v2/device"> Streams API </a>
  """
  use M2X.Subresource, path: {"/streams", :name}

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#List-Data-Stream-Values">List Data Stream Values</a> endpoint.

    List values from the Stream matching the given optional search parameters.

    - stream: M2X.Stream struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: The API response, see M2X API docs for details
  """
  def values(stream = %M2X.Stream { client: client }, params\\nil) do
    M2X.Client.get(client, path(stream)<>"/values", params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#List-Data-Stream-Sampling">List Data Stream Sampling</a> endpoint.

    Sample values from the Stream matching the given optional search parameters.

    - stream: M2X.Stream struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: The API response, see M2X API docs for details
  """
  def sampling(stream = %M2X.Stream { client: client }, params\\nil) do
    M2X.Client.get(client, path(stream)<>"/sampling", params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#List-Data-Stream-Stats">List Data Stream Stats</a> endpoint.

    Get statistics calculated from the values of the Stream, with optional parameters.

    - stream: M2X.Stream struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: The API response, see M2X API docs for details
  """
  def stats(stream = %M2X.Stream { client: client }, params\\nil) do
    M2X.Client.get(client, path(stream)<>"/stats", params)
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Update-Data-Stream-Value">Update Data Stream Value</a> endpoint.

    Update the current value of the stream, with optional timestamp.

    - stream: M2X.Stream struct
    - value: The updated stream value
    - Returns: The API response, see M2X API docs for details
  """
  def update_value(stream = %M2X.Stream { client: client }, value) do
    M2X.Client.put(client, path(stream)<>"/value", %{ value: value })
  end
  def update_value(stream = %M2X.Stream { client: client }, value, timestamp) do
    M2X.Client.put(client, path(stream)<>"/value", %{ value: value, timestamp: timestamp })
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Post-Data-Stream-Values">Post Data Stream Values</a> endpoint.

    Post a list of multiple values with timestamps to the Stream.

    - stream: M2X.Stream struct
    - values: Values to post, see M2X API docs for details
    - Returns: The API response, see M2X API docs for details
  """
  def post_values(stream = %M2X.Stream { client: client }, values) do
    M2X.Client.post(client, path(stream)<>"/values", %{ values: values })
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/device#Delete-Data-Stream-Values">Delete Data Stream Values</a> endpoint.

    Delete values in a Stream by a date range.

    - stream: M2X.Stream struct
    - start: ISO8601 timestamp for starting timerange for values to be deleted
    - stop: ISO8601 timestamp for ending timerange for values to be deleted
    - Returns: The API response, see M2X API docs for details
  """
  def delete_values!(stream = %M2X.Stream { client: client }, start, stop) do
    M2X.Client.delete(client, path(stream)<>"/values", %{ from: start, end: stop })
  end

end
