defmodule M2X.Subresource do
  @moduledoc """
    Common behaviour module for M2X Subresources.
  """
  defmacro __using__(opts) do
    {:ok, path} = Keyword.fetch(opts, :path)
    {main_path, uid} = path
    uid = to_string(uid)

    quote location: :keep do
      defstruct \
        client: nil,
        attrs: %{},
        under: nil

      alias __MODULE__, as: TheModule

      @main_path unquote(main_path)

      @doc """
        Return the API path of the Subresource.
      """
      def path(%TheModule { under: under, attrs: %{ unquote(uid)=>uid } }) do
        path(under, uid)
      end
      def path(under, uid) when is_binary(under) and is_binary(uid) do
        under<>@main_path<>"/"<>uid
      end

      @doc """
        Query the service and return a refreshed version of the same
        subresource struct with all attrs set to their latest values.
      """
      def refreshed(subresource = %TheModule { client: client }) do
        case M2X.Client.get(client, TheModule.path(subresource)) do
          {:ok, res} -> {:ok, %TheModule { subresource | attrs: res.json }}
          error_pair -> error_pair
        end
      end

      @doc """
        Update the remote subresource using the given attrs.
      """
      def update!(subresource = %TheModule { client: client }, params) do
        M2X.Client.put(client, TheModule.path(subresource), params)
      end

      @doc """
        Delete the remote subresource.
      """
      def delete!(subresource = %TheModule { client: client }) do
        M2X.Client.delete(client, TheModule.path(subresource))
      end

    end
  end
end
