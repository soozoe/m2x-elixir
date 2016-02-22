defmodule M2X.BareResource do
  @moduledoc """
    Common behaviour module for modules that aren't full M2X Resources.
  """
  defmacro __using__(opts) do
    {:ok, path} = Keyword.fetch(opts, :path)
    {main_path, _} = path

    quote location: :keep do
      defstruct \
        client: nil,
        attrs: %{}

      @main_path unquote(main_path)

    end
  end
end
