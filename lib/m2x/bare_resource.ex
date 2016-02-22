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

      alias __MODULE__, as: TheModule

      # Implement Access protocol to delegate struct[key] to struct.attrs[key]
      defimpl Access, for: TheModule do
        def get(%TheModule { attrs: attrs }, key) do
          Map.get(attrs, key)
        end
        def get_and_update(%TheModule { attrs: attrs }, key, fun) do
          current_value = Map.get(attrs, key)
          {get, update} = fun.(current_value)
          {get, Map.put(key, update, attrs)}
        end
      end

      @main_path unquote(main_path)

    end
  end
end
