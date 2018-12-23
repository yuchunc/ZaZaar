defmodule ZaZaar.Fb.ApiBehaviour do
  @type access_token :: String.t()
  @type object_id :: String.t()
  @type fields :: String.t() | list()
  @type resp :: Facebook.resp()
  @type opts :: keyword

  @callback me(fields, access_token) :: resp
  @callback get_object_edge(String.t(), object_id, access_token, opts) :: resp
  @callback get_edge_objects(String.t(), list(object_id), access_token, opts) :: resp
end
