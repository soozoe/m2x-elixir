# Common tests for modules with M2X.Resource behaviour
defmodule M2X.SubresourceTest.Common do
  defmacro __using__(opts) do
    {:ok, mod}   = Keyword.fetch(opts, :mod)
    {:ok, under} = Keyword.fetch(opts, :under)

    quote location: :keep do
      alias unquote(mod),   as: TheModule
      alias unquote(under), as: ParentModule

      def test_attrs do
        Map.merge required_attrs,
          %{ "foo"=>88, "bar"=>"ninety-nine" }
      end

      def new_test_attrs do
        Map.merge required_attrs,
          %{ "foo"=>99, "bar"=>"eighty-eight", "baz"=>true }
      end

      def mock_subject(request, response) do
        %TheModule {
          client: MockEngine.client(request, response),
          attrs: test_attrs,
          under: under_path
        }
      end

      test "attribute access" do
        subject = %TheModule { attrs: test_attrs }

        assert subject.attrs  == test_attrs
        assert subject["foo"] == test_attrs["foo"]
        assert subject["bar"] == test_attrs["bar"]
      end

      test "refreshed" do
        subject = mock_subject \
          {:get, path, nil},
          {200, new_test_attrs, nil}
        assert subject.attrs == test_attrs
        {:ok, new_subject} = TheModule.refreshed(subject)

        %TheModule { } = new_subject
        assert new_subject.client == subject.client
        assert new_subject.attrs  == new_test_attrs
      end

      test "update!" do
        subject = mock_subject \
          {:put, path, new_test_attrs},
          {204, nil, nil}

        {:ok, res} = TheModule.update!(subject, new_test_attrs)
        assert res.status == 204
      end

      test "delete!" do
        subject = mock_subject \
          {:delete, path, nil},
          {204, nil, nil}

        {:ok, res} = TheModule.delete!(subject)
        assert res.status == 204
      end

    end
  end
end

defmodule M2X.SubresourceTest.Device.Stream do
  use ExUnit.Case
  use M2X.SubresourceTest.Common, mod: M2X.Stream, under: M2X.Device
  doctest M2X.Stream

  def name           do "temperature"                         end
  def device_id      do "0123456789abcdef0123456789abcdef"    end
  def under_path     do "/devices/"<>device_id                end
  def main_path      do "/v2"<>under_path<>"/streams"         end
  def path           do main_path<>"/"<>name                  end
  def required_attrs do %{ "name" => name }                   end
end
