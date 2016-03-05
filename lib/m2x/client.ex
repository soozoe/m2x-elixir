defmodule M2X.Client do

  def version, do: "2.0.0"

  @os_type    :os.type
  @os_version :os.version

  def user_agent do
    {os_family, os_name} = @os_type
    {os_family, os_name} = {to_string(os_family), to_string(os_name)}
    os_version = case @os_version do
      {maj,min,rel} -> to_string(maj)<>"."<>to_string(min)<>"."<>to_string(rel)
      string        -> to_string(string)
    end
    "M2X-Elixir/" <> version <> \
     " elixir/" <> System.version <> \
     " erlang/" <> to_string(:erlang.system_info(:otp_release)) <> \
      " (" <> os_family <> ":" <> os_name <> " " <> os_version <> ")"
  end

  @ssl_cacertfile __DIR__ <> "/cacert.pem"

  @default_api_base    "https://api-m2x.att.com"
  @default_api_version :v2

  defstruct \
    api_base:    @default_api_base,
    api_version: @default_api_version,
    api_key:     nil,
    http_engine: :hackney

  defmodule Response do
    defstruct \
      raw:     "",
      json:    %{},
      status:  0,
      headers: %{}
  end

  # Define REST methods for accessing the M2X API directly.
  for method <- [:get, :post, :put, :delete, :head, :options, :patch] do
    def unquote(method)(client = %M2X.Client{}, path, params\\nil, headers\\%{}) when is_binary(path) do
      request(client, unquote(method), path, params, headers)
    end
  end

  ##
  # Private functions

  defp request(client, verb, path, params, headers, options\\%{}) do
    url             = make_url(client, path)
    {body, headers} = make_body(params, headers)
    header_list     = Map.to_list(headers) ++ [
      {"X-M2X-KEY", client.api_key},
      {"User-Agent", user_agent},
    ]
    option_list     = Map.to_list(options) ++ [
      ssl_options: [{:cacertfile, @ssl_cacertfile}]
    ]

    engine = client.http_engine
    engine.start
    make_response engine,
      engine.request(verb, url, header_list, body, option_list)
  end

  defp make_response(engine, {:ok, status, header_list, body_ref}) do
    {:ok, body}  = engine.body(body_ref)
    headers      = Enum.into(header_list, %{})
    content_type = headers["Content-Type"]
    is_json      = !!content_type and String.starts_with? content_type, "application/json"
    {:ok, json}  = cond do
                     is_json -> JSON.decode(body)
                     true    -> {:ok, nil}
                   end

    response = %Response {
      raw:     body,
      json:    json,
      status:  status,
      headers: headers,
    }

    case div(status, 100) do
      2 -> {:ok, response}
      _ -> {:error, response}
    end
  end

  defp make_body(nil, headers) do {"", headers} end
  defp make_body(body, headers) when is_binary(body) do {body, headers} end
  defp make_body(params, headers) when is_map(params) do
    case headers["Content-Type"] do
      "application/json" ->
        {:ok, body} = JSON.encode(params)
        {body, headers}
      nil ->
        headers = Map.put(headers, "Content-Type", "application/json")
        make_body(params, headers)
    end
  end

  defp make_url(client, path) do
    case path do
      << "/"::utf8, _::binary >> -> path = path
      _                          -> path = "/" <> path
    end
    unless Regex.match?(~r"\A/v\d+/", path) do
      path = "/" <> Atom.to_string(client.api_version) <> path
    end
    client.api_base <> path
  end

end
