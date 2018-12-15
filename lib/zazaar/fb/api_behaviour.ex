defmodule ZaZaar.Fb.ApiBehaviour do
  @type access_token :: String.t()
  @type fields :: String.t() | list()
  @type resp :: Facebook.resp()

  @callback me(fields, access_token) :: resp
end
