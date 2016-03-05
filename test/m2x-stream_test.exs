defmodule M2X.StreamTest do
  use ExUnit.Case
  doctest M2X.Stream

  def mock_subject(request, response) do
    %M2X.Stream {
      client: MockEngine.client(request, response),
      attrs: test_attrs,
      under: "/devices/"<>device_id,
    }
  end

  def name       do "temperature"                         end
  def device_id  do "0123456789abcdef0123456789abcdef"    end
  def test_attrs do
    %{ "name"=>name, "type"=>"numeric" }
  end

  def test_list do
    [ %{ "timestamp"=>"2014-09-09T19:15:00.981Z", "value"=>32 },
      %{ "timestamp"=>"2014-09-09T20:15:00.124Z", "value"=>30 },
      %{ "timestamp"=>"2014-09-09T21:15:00.124Z", "value"=>15 } ]
  end

  def test_value_only do
    %{ "value"=>32 }
  end

  def test_value_timed do
    %{ "timestamp"=>"2014-09-09T19:15:00.981Z", "value"=>32 }
  end

  test "values/1" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>device_id<>"/streams/"<>name<>"/values", nil},
      {200, %{ "values" => test_list }, nil}

    {:ok, res} = M2X.Stream.values(subject)
    assert res.json["values"] == test_list
  end

  test "values/2" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>device_id<>"/streams/"<>name<>"/values", test_attrs},
      {200, %{ "values" => test_list }, nil}

    {:ok, res} = M2X.Stream.values(subject, test_attrs)
    assert res.json["values"] == test_list
  end

  test "sampling/1" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>device_id<>"/streams/"<>name<>"/sampling", nil},
      {200, %{ "sampling" => test_list }, nil}

    {:ok, res} = M2X.Stream.sampling(subject)
    assert res.json["sampling"] == test_list
  end

  test "sampling/2" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>device_id<>"/streams/"<>name<>"/sampling", test_attrs},
      {200, %{ "sampling" => test_list }, nil}

    {:ok, res} = M2X.Stream.sampling(subject, test_attrs)
    assert res.json["sampling"] == test_list
  end

  test "stats/1" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>device_id<>"/streams/"<>name<>"/stats", nil},
      {200, %{ "stats" => test_list }, nil}

    {:ok, res} = M2X.Stream.stats(subject)
    assert res.json["stats"] == test_list
  end

  test "stats/2" do
    subject = mock_subject \
      {:get, "/v2/devices/"<>device_id<>"/streams/"<>name<>"/stats", test_attrs},
      {200, %{ "stats" => test_list }, nil}

    {:ok, res} = M2X.Stream.stats(subject, test_attrs)
    assert res.json["stats"] == test_list
  end

  test "update_value/1" do
    value = test_value_only["value"]
    subject = mock_subject \
      {:put, "/v2/devices/"<>device_id<>"/streams/"<>name<>"/value", test_value_only},
      {202, nil, nil}

    {:ok, res} = M2X.Stream.update_value(subject, value)
    assert res.status == 202
  end

  test "update_value/2" do
    {value, timestamp} = {test_value_timed["value"], test_value_timed["timestamp"]}
    subject = mock_subject \
      {:put, "/v2/devices/"<>device_id<>"/streams/"<>name<>"/value", test_value_timed},
      {202, nil, nil}

    {:ok, res} = M2X.Stream.update_value(subject, value, timestamp)
    assert res.status == 202
  end

  test "post_values" do
    subject = mock_subject \
      {:post, "/v2/devices/"<>device_id<>"/streams/"<>name<>"/values", %{ "values"=>test_list }},
      {202, nil, nil}

    {:ok, res} = M2X.Stream.post_values(subject, test_list)
    assert res.status == 202
  end

  test "delete_values!" do
    {start, stop} = {"2014-09-09T19:15:00.624Z", "2014-09-09T20:15:00.522Z"}
    subject = mock_subject \
      {:delete, "/v2/devices/"<>device_id<>"/streams/"<>name<>"/values", %{ "from"=>start, "end"=>stop }},
      {204, nil, nil}

    {:ok, res} = M2X.Stream.delete_values!(subject, start, stop)
    assert res.status == 204
  end

end
