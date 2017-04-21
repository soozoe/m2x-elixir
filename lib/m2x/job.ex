defmodule M2X.Job do
  @moduledoc """
    Wrapper for the AT&T M2X <a href="https://m2x.att.com/developer/documentation/v2/jobs"> Jobs API </a>
  """
  use M2X.BareResource, path: {"/jobs", :job}

  @doc """
    Return the API path of the Resource.
  """
  def path(%M2X.Job { attrs: %{ :job => uid } }) do
    path(uid)
  end
  def path(uid) when is_binary(uid) do
    @main_path<>"/"<>uid
  end

  @doc """
    Method for <a href="https://m2x.att.com/developer/documentation/v2/jobs#View-Job-Details">View Job Details</a> endpoint.

    Retrieve a view of the Job associated with the given unique job id.

    - client: M2X.Client struct
    - job: ID of the Job to retrieve
    - Returns: The matching Job
  """
  def fetch(client = %M2X.Client{}, job) do
    case M2X.Client.get(client, path(job)) do
      {:ok, res} -> {:ok, %M2X.Job { client: client, attrs: res.json }}
      error_pair -> error_pair
    end
  end

end
