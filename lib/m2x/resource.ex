defmodule M2X.Resource do
  @moduledoc """
    Common behaviour module for M2X Resources.
  """
  defmacro __using__(opts) do
    {:ok, path} = Keyword.fetch(opts, :path)
    {main_path, uid} = path
    uid = to_string(uid)

    quote location: :keep do
      defstruct \
        client: nil,
        attrs: %{}

      alias __MODULE__, as: TheModule

      @main_path unquote(main_path)

      @doc """
        Return the API path of the Resource.
      """
      def path(%TheModule { attrs: %{ unquote(uid)=>uid } }) do
        path(uid)
      end
      def path(uid) when is_binary(uid) do
        @main_path<>"/"<>uid
      end

      @doc """
        Create a new resource using the given client and optional params,
        returning a struct with the attrs of the new resource.
      """
      def create!(client = %M2X.Client{}, params\\%{}) do
        case M2X.Client.post(client, @main_path, params) do
          {:ok, res} -> {:ok, %TheModule { client: client, attrs: res.json }}
          error_pair -> error_pair
        end
      end

      @doc """
        Query the service and return a refreshed version of the same
        resource struct with all attrs set to their latest values.
      """
      def refreshed(resource = %TheModule { client: client }) do
        case M2X.Client.get(client, TheModule.path(resource)) do
          {:ok, res} -> {:ok, %TheModule { resource | attrs: res.json }}
          error_pair -> error_pair
        end
      end

      @doc """
        Update the remote resource using the given attrs.
      """
      def update!(resource = %TheModule { client: client }, params) do
        M2X.Client.put(client, TheModule.path(resource), params)
      end

      @doc """
        Delete the remote resource.
      """
      def delete!(resource = %TheModule { client: client }) do
        M2X.Client.delete(client, TheModule.path(resource))
      end

    end
  end
end
