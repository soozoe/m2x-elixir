defmodule M2X.DeviceTest do
  use ExUnit.Case
  doctest M2X.Device

  def mock_subject(request, response) do
    %M2X.Device {
      client: MockEngine.client(request, response),
      attrs: test_attrs,
    }
  end

  def id do
    "0123456789abcdef0123456789abcdef"
  end

  def test_attrs do
    %{ "id"=>id, "name"=>"test", "visibility"=>"public", "description"=>"foo" }
  end

  def test_location do
    Enum.at(test_locations, 0)
  end

  def test_locations do
    [ %{ "latitude"=>-37.9788423, "longitude"=>-57.5478776, "elevation"=>5 },
      %{ "latitude"=>-37.9788219, "longitude"=>-57.5478328, "elevation"=>9 } ]
  end

  def test_sub do
    Enum.at(test_sublist, 0)
  end

  def test_sublist do
    [ %{ "id"=>"a123", "name"=>"test" },
      %{ "id"=>"b123", "name"=>"test" },
      %{ "id"=>"c123", "name"=>"test" } ]
  end

  test "fetch" do
    client = MockEngine.client \
      {:get, "/v2/devices/"<>id, nil},
      {200, test_attrs, nil}
    {:ok, subject} = M2X.Device.fetch(client, id)

    %M2X.Device { } = subject
    assert subject.client == client
    assert subject.attrs  == test_attrs
  end

  test "list, catalog" do
    params = %{ q: "test" }
    <<_::binary-size(1), suffix::binary>> = id
    result = %{ devices: [
      %{ id: "a"<>suffix, name: "test", description: "foo" },
      %{ id: "b"<>suffix, name: "test", description: "bar" },
      %{ id: "c"<>suffix, name: "test", description: "baz" },
    ]}

    client = MockEngine.client({:get, "/v2/devices", nil}, {200, result, nil})
    {:ok, list} = M2X.Device.list(client)

    client = MockEngine.client({:get, "/v2/devices/search", nil}, {200, result, nil})
    {:ok, search} = M2X.Device.search(client)

    client = MockEngine.client({:get, "/v2/devices/catalog", nil}, {200, result, nil})
    {:ok, catalog} = M2X.Device.catalog(client)

    client = MockEngine.client({:get, "/v2/devices", params}, {200, result, nil})
    {:ok, list2} = M2X.Device.list(client, params)

    client = MockEngine.client({:get, "/v2/devices/search", params}, {200, result, nil})
    {:ok, search2} = M2X.Device.search(client, params)

    client = MockEngine.client({:get, "/v2/devices/catalog", params}, {200, result, nil})
    {:ok, catalog2} = M2X.Device.catalog(client, params)

    for list <- [list, search, catalog, list2, search2, catalog2] do
      for subject = %M2X.Device{} <- list do
        assert subject.client == client
        assert subject["name"] == "test"
      end
      assert Enum.at(list, 0)["id"] == "a"<>suffix
      assert Enum.at(list, 1)["id"] == "b"<>suffix
      assert Enum.at(list, 2)["id"] == "c"<>suffix
    end
  end

  test "get_location" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>id<>"/location", nil},
      {200, test_location, nil}

    {:ok, res} = M2X.Device.get_location(subject)
    assert res.json == test_location
  end

  test "location_history" do
    params = %{ "limit" => 2 }
    subject = mock_subject \
      {:get, "/v2/devices/"<>id<>"/location/waypoints", params},
      {200, %{ "waypoints" => test_locations }, nil}

    {:ok, res} = M2X.Device.location_history(subject, params)
    assert res.json == %{ "waypoints" => test_locations }
  end

  test "update_location" do
    subject = mock_subject \
      {:put, "/v2/devices/"<>id<>"/location", test_location},
      {202, nil, nil}

    {:ok, res} = M2X.Device.update_location(subject, test_location)
    assert res.status == 202
  end

  test "metadata" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>id<>"/metadata", nil},
      {200, test_sub, nil}

    {:ok, res} = M2X.Device.metadata(subject)
    assert res.json == test_sub
  end

  test "update_metadata" do
    subject = mock_subject \
      {:put, "/v2/devices/"<>id<>"/metadata", test_sub},
      {202, nil, nil}

    {:ok, res} = M2X.Device.update_metadata(subject, test_sub)
    assert res.status == 202
  end

  test "get_metadata_field" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>id<>"/metadata/field_name", nil},
      {200, test_sub, nil}

    {:ok, res} = M2X.Device.get_metadata_field(subject, "field_name")
    assert res.json == test_sub
  end

  test "set_metadata_field" do
    subject = mock_subject \
      {:put, "/v2/devices/"<>id<>"/metadata/field_name", %{ "value" => "field_value" }},
      {202, nil, nil}

    {:ok, res} = M2X.Device.set_metadata_field(subject, "field_name", "field_value")
    assert res.status == 202
  end

  test "values" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>id<>"/values", test_attrs},
      {200, %{ "values" => test_sublist }, nil}

    {:ok, res} = M2X.Device.values(subject, test_attrs)
    assert res.json == %{ "values" => test_sublist }
  end

  test "values_search" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>id<>"/values/search", test_attrs},
      {200, %{ "values" => test_sublist }, nil}

    {:ok, res} = M2X.Device.values_search(subject, test_attrs)
    assert res.json == %{ "values" => test_sublist }
  end

  test "values_export_csv/1" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>id<>"/values/export.csv", %{}},
      {202, nil, nil}

    {:ok, res} = M2X.Device.values_export_csv(subject)
    assert res.status == 202
  end

  test "values_export_csv/2" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>id<>"/values/export.csv", test_attrs},
      {202, nil, nil}

    {:ok, res} = M2X.Device.values_export_csv(subject, test_attrs)
    assert res.status == 202
  end

  test "post_update" do
    params = %{
      timestamp: "2014-09-09T20:15:00.124Z",
      values: %{
        temperature: 32,
        humidity: 88
      }
    }
    subject = mock_subject \
      {:post, "/v2/devices/"<>id<>"/update", params},
      {202, nil, nil}

    {:ok, res} = M2X.Device.post_update(subject, params)
    assert res.status == 202
  end

  test "post_updates" do
    params = %{ values: %{
      temperature: [
        %{ timestamp: "2014-09-09T19:15:00.981Z", "value": 32 },
        %{ timestamp: "2014-09-09T20:15:00.124Z", "value": 30 },
        %{ timestamp: "2014-09-09T21:15:00.124Z", "value": 15 } ],
      humidity: [
        %{ timestamp: "2014-09-09T19:15:00.874Z", "value": 88 },
        %{ timestamp: "2014-09-09T20:15:00.752Z", "value": 60 },
        %{ timestamp: "2014-09-09T21:15:00.752Z", "value": 75 } ]
    }}
    subject = mock_subject \
      {:post, "/v2/devices/"<>id<>"/updates", params},
      {202, nil, nil}

    {:ok, res} = M2X.Device.post_updates(subject, params)
    assert res.status == 202
  end

  test "streams" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>id<>"/streams", nil},
      {200, %{ "streams"=>test_sublist }, nil}

    {:ok, streams} = M2X.Device.streams(subject)

    for stream = %M2X.Stream{} <- streams do
      assert stream.client == subject.client
      assert stream.under == "/devices/"<>id
    end
    assert Enum.at(streams, 0).attrs == Enum.at(test_sublist, 0)
    assert Enum.at(streams, 1).attrs == Enum.at(test_sublist, 1)
    assert Enum.at(streams, 2).attrs == Enum.at(test_sublist, 2)
  end

  test "stream" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>id<>"/streams/"<>test_sub["name"], nil},
      {200, test_sub, nil}

    {:ok, stream} = M2X.Device.stream(subject, test_sub["name"])

    %M2X.Stream{} = stream
    assert stream.client == subject.client
    assert stream.under  == "/devices/"<>id
    assert stream.attrs  == test_sub
  end

  test "update_stream, create_stream" do
    update_attrs = %{ "foo"=>"bar" }
    subject = mock_subject \
      {:put, "/v2/devices/"<>id<>"/streams/"<>test_sub["name"], update_attrs},
      {204, nil, nil}

    {:ok, res} = M2X.Device.update_stream(subject, test_sub["name"], update_attrs)
    assert res.status == 204

    subject = mock_subject \
      {:put, "/v2/devices/"<>id<>"/streams/"<>test_sub["name"], update_attrs},
      {204, nil, nil}

    {:ok, res} = M2X.Device.create_stream(subject, test_sub["name"], update_attrs)
    assert res.status == 204
  end

  test "commands" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>id<>"/commands", nil},
      {200, %{ "commands"=>test_sublist }, nil}

    {:ok, commands} = M2X.Device.commands(subject)

    for command = %M2X.Stream{} <- commands do
      assert command.client == subject.client
    end
    assert Enum.at(commands, 0).attrs == Enum.at(test_sublist, 0)
    assert Enum.at(commands, 1).attrs == Enum.at(test_sublist, 1)
    assert Enum.at(commands, 2).attrs == Enum.at(test_sublist, 2)
  end

  test "command" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>id<>"/commands/"<>test_sub["id"], nil},
      {200, test_sub, nil}

    {:ok, command} = M2X.Device.command(subject, test_sub["id"])

    %M2X.Command{} = command
    assert command.client == subject.client
    assert command.attrs == test_sub
  end

  test "process_command" do
    params = %{ foo: "abc", bar: "xyz" }
    subject = mock_subject \
      {:post, "/v2/devices/"<>id<>"/commands/"<>test_sub["id"]<>"/process", params},
      {202, nil, nil}

    command = %M2X.Command { attrs: test_sub }

    {:ok, res} = M2X.Device.process_command(subject, command, params)
    assert res.status == 202
  end

  test "reject_command" do
    params = %{ foo: "abc", bar: "xyz" }
    subject = mock_subject \
      {:post, "/v2/devices/"<>id<>"/commands/"<>test_sub["id"]<>"/reject", params},
      {202, nil, nil}

    command = %M2X.Command { attrs: test_sub }

    {:ok, res} = M2X.Device.reject_command(subject, command, params)
    assert res.status == 202
  end

end
