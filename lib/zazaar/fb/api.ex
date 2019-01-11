defmodule ZaZaar.Fb.Api do
  @behaviour ZaZaar.Fb.ApiBehaviour

  alias Facebook.{GraphAPI, Config, ResponseFormatter}

  @type object_ids :: list | String.t()
  @type resp :: Facebook.resp()

  defdelegate me(fields, access_token), to: Facebook

  defdelegate get_object_edge(edge, object_id, access_token, params \\ []), to: Facebook

  defdelegate stream(api_request), to: Facebook.Stream, as: :new

  defdelegate publish(edge, object_id, inputs, access_token), to: Facebook

  @spec remove(edge :: atom, object_id :: String.t(), access_token :: String.t()) :: resp
  def remove(edge, object_id, access_token) do
    params1 =
      []
      |> add_app_secret(access_token)
      |> add_access_token(access_token)

    ~s(/#{object_id}/#{edge})
    |> GraphAPI.delete([], params: params1)
    |> ResponseFormatter.format_response()
  end

  @spec get_object_edge(String.t(), object_ids, String.t()) :: resp
  def get_edge_objects(edge, object_ids, access_token) do
    get_edge_objects(edge, object_ids, access_token, [])
  end

  @spec get_object_edge(String.t(), object_ids, String.t(), keyword) :: resp
  def get_edge_objects(edge, object_ids, access_token, params) when is_list(object_ids) do
    get_edge_objects(edge, Enum.join(object_ids, ","), access_token, params)
  end

  def get_edge_objects(edge, object_ids, access_token, params) do
    params =
      (params ++ [ids: object_ids])
      |> add_app_secret(access_token)
      |> add_access_token(access_token)

    ~s(/#{edge})
    |> GraphAPI.get([], params: params)
    |> ResponseFormatter.format_response()
  end

  # Add the appsecret_proof to the GraphAPI request params if the app secret is
  # defined
  defp add_app_secret(params, access_token) do
    if is_nil(Config.app_secret()) do
      params
    else
      params ++ [appsecret_proof: signature_base16(access_token)]
    end
  end

  ## Add access_token to params
  defp add_access_token(fields, token) do
    fields ++ [access_token: token]
  end

  # Hashes the token together with the app secret according to the
  # guidelines of facebook to build an unencoded/raw signature.
  defp signature(str) do
    :crypto.hmac(:sha256, Config.app_secret(), str)
  end

  # Uses signature/1 to build a lowercase base16-encoded signature
  defp signature_base16(str) do
    str |> signature() |> Base.encode16(case: :lower)
  end
end
