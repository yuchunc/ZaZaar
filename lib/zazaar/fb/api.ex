defmodule ZaZaar.Fb.Api do
  @behaviour ZaZaar.Fb.ApiBehaviour

  defdelegate me(fields, access_token), to: Facebook
end
