defmodule ZaZaar.Fb.Api do
  @behaviour ZaZaar.Fb.ApiBehaviour

  alias Facebook.{GraphAPI, Config, ResponseFormatter}

  defdelegate me(fields, access_token), to: Facebook

  defdelegate get_object_edge(edge, object_id, access_token, params \\ []), to: Facebook

  @spec get_object_edge(String.t(), [String.t()], String.t(), keyword) ::
          {:ok, map} | {:error, map}
  def get_edge_objects(edge, object_ids, access_token, params \\ []) do
    params =
      params
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
