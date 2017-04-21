defmodule M2X.Key do
  @moduledoc """
    Wrapper for the AT&T M2X <a href="https://m2x.att.com/developer/documentation/v2/keys"> Keys API </a>
  """
  use M2X.Resource, path: {"/keys", :key}

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/keys#View-Key-Details">View Key Details</a> endpoint.

    Retrieve a view of the Key associated with the given unique key string.

    - client: M2X.Client struct
    - key: ID of the Key to retrieve
    - Returns: The matching Key
  """
  def fetch(client = %M2X.Client{}, key) do
    case M2X.Client.get(client, path(key)) do
      {:ok, res} -> {:ok, %M2X.Key { client: client, attrs: res.json }}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/keys#List-Keys">List Keys</a> endpoint.

    Retrieve the list of keys associated with the specified account that
    meet the search criteria.

    - client: M2X.Client struct
    - params: Query parameters passed as keyword arguments. View M2X API Docs for listing of available parameters
    - Returns: List of Key
  """
  def list(client = %M2X.Client{}, params\\nil) do
    case M2X.Client.get(client, @main_path, params) do
      {:ok, res} ->
        list = Enum.map res.json["keys"], fn (attrs) ->
          %M2X.Key { client: client, attrs: attrs }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/keys#Regenerate-Key">Regenerate Key</a> endpoint.

    Regenerate an API Key token and return the regenerated Key.

    Note that if you regenerate the key that you're using for
    authentication then you would need to change your scripts to
    start using the new key token for all subsequent requests.
  """
  def regenerated(key = %M2X.Key { client: client }) do
    case M2X.Client.get(client, path(key)) do
      {:ok, res} -> {:ok, %M2X.Key { key | attrs: res.json }}
      error_pair -> error_pair
    end
  end

end
