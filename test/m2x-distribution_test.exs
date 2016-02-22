defmodule M2X.DistributionTest do
  use ExUnit.Case
  doctest M2X.Distribution

  def mock_subject(request, response) do
    %M2X.Distribution {
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
      {:get, "/v2/distributions/"<>id, nil},
      {200, test_attrs, nil}
    {:ok, subject} = M2X.Distribution.fetch(client, id)

    %M2X.Distribution { } = subject
    assert subject.client == client
    assert subject.attrs  == test_attrs
  end

  test "metadata" do
    subject = mock_subject \
      {:get, "/v2/distributions/"<>id<>"/metadata", nil},
      {200, test_sub, nil}

    {:ok, res} = M2X.Distribution.metadata(subject)
    assert res.json == test_sub
  end

  test "update_metadata" do
    subject = mock_subject \
      {:put, "/v2/distributions/"<>id<>"/metadata", test_sub},
      {202, nil, nil}

    {:ok, res} = M2X.Distribution.update_metadata(subject, test_sub)
    assert res.status == 202
  end

  test "get_metadata_field" do
    subject = mock_subject \
      {:get, "/v2/distributions/"<>id<>"/metadata/field_name", nil},
      {200, test_sub, nil}

    {:ok, res} = M2X.Distribution.get_metadata_field(subject, "field_name")
    assert res.json == test_sub
  end

  test "set_metadata_field" do
    subject = mock_subject \
      {:put, "/v2/distributions/"<>id<>"/metadata/field_name", %{ "value" => "field_value" }},
      {202, nil, nil}

    {:ok, res} = M2X.Distribution.set_metadata_field(subject, "field_name", "field_value")
    assert res.status == 202
  end

  test "list" do
    params = %{ q: "test" }
    <<_::binary-size(1), suffix::binary>> = id
    result = %{ distributions: [
      %{ id: "a"<>suffix, name: "test", description: "foo" },
      %{ id: "b"<>suffix, name: "test", description: "bar" },
      %{ id: "c"<>suffix, name: "test", description: "baz" },
    ]}

    client = MockEngine.client({:get, "/v2/distributions", nil}, {200, result, nil})
    {:ok, list} = M2X.Distribution.list(client)

    client = MockEngine.client({:get, "/v2/distributions", params}, {200, result, nil})
    {:ok, list2} = M2X.Distribution.list(client, params)

    for list <- [list, list2] do
      for subject = %M2X.Distribution{} <- list do
        assert subject.client == client
        assert subject["name"] == "test"
      end
      assert Enum.at(list, 0)["id"] == "a"<>suffix
      assert Enum.at(list, 1)["id"] == "b"<>suffix
      assert Enum.at(list, 2)["id"] == "c"<>suffix
    end
  end

  test "devices" do
    params = %{ q: "test" }
    <<_::binary-size(1), suffix::binary>> = id
    result = %{ devices: [
      %{ id: "a"<>suffix, name: "test", description: "foo" },
      %{ id: "b"<>suffix, name: "test", description: "bar" },
      %{ id: "c"<>suffix, name: "test", description: "baz" },
    ]}

    subject = mock_subject {:get, "/v2/distributions/"<>id<>"/devices", nil}, {200, result, nil}
    {:ok, devices} = M2X.Distribution.devices(subject)

    subject = mock_subject {:get, "/v2/distributions/"<>id<>"/devices", params}, {200, result, nil}
    {:ok, devices2} = M2X.Distribution.devices(subject, params)

    for devices <- [devices, devices2] do
      for subject = %M2X.Device{} <- devices do
        assert subject.client == subject.client
        assert subject["name"] == "test"
      end
      assert Enum.at(devices, 0)["id"] == "a"<>suffix
      assert Enum.at(devices, 1)["id"] == "b"<>suffix
      assert Enum.at(devices, 2)["id"] == "c"<>suffix
    end
  end

  test "add_device" do
    serial = "ABC1234"
    params = %{ "serial"=>serial }
    subject = mock_subject \
      {:post, "/v2/distributions/"<>id<>"/devices", params},
      {200, test_attrs, nil}
    {:ok, device} = M2X.Distribution.add_device(subject, serial)

    %M2X.Device { } = device
    assert device.client == subject.client
    assert device.attrs  == test_attrs
  end

end
