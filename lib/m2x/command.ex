defmodule M2X.Command do
  @moduledoc """
    Wrapper for the AT&T M2X <a href="https://m2x.att.com/developer/documentation/v2/commands"> Commands API </a>
  """
  use M2X.BareResource, path: {"/commands", :id}

  @doc """
    Return the API path of the Command.
  """
  def path(%M2X.Command { attrs: %{ "id" => uid } }) do
    path(uid)
  end
  def path(uid) when is_binary(uid) do
    @main_path<>"/"<>uid
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/commands#List-Commands">List Commands</a> endpoint.

    Retrieve the list of Commands accessible by the authenticated API key.

    - client: M2X.Client struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: List of Commands
  """
  def list(client = %M2X.Client{}, params\\nil) do
    case M2X.Client.get(client, @main_path, params) do
      {:ok, res} ->
        list = Enum.map res.json["commands"], fn (attrs) ->
          %M2X.Command { client: client, attrs: attrs }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/commands#View-Command-Details">View Command Details</a> endpoint.

    Retrieve a view of the Command associated with the given command id.

    - client: M2X.Client struct
    - id: ID of the Command to retrieve
    - Returns: The matching Command

  """
  def fetch(client = %M2X.Client{}, id) do
    case M2X.Client.get(client, path(id)) do
      {:ok, res} -> {:ok, %M2X.Command { client: client, attrs: res.json }}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/commands#Send-Command">Send Command</a> endpoint.

    Send a Command with the given name and data to the given targets.

    - client: M2X.Client struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: The Command that was just sent
  """
  def send(client = %M2X.Client{}, params) do
    {:ok, res} = M2X.Client.post(client, @main_path, params)

    case Map.fetch(res.headers, "Location") do
      {:ok, location} ->
        uid = List.last(String.split(location, "/"))
        {:ok, %M2X.Command { client: client, attrs: %{ "id" => uid } }}
      _ -> {:error, res}
    end
  end

end
