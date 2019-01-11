defmodule ZaZaar.Fb.ApiBehaviour do
  @type fb_edge :: atom
  @type access_token :: String.t()
  @type object_id :: String.t()
  @type fields :: String.t() | list()
  @type inputs :: keyword
  @type resp :: Facebook.resp()
  @type opts :: keyword

  @callback me(fields, access_token) :: resp
  @callback get_edge_objects(String.t(), list(object_id), access_token, opts) :: resp
  @callback get_object_edge(String.t(), object_id, access_token, opts) :: resp
  @callback stream(Map.t()) :: Enumerable.t()
  @callback publish(fb_edge, object_id, inputs, access_token) :: resp
  @callback remove(fb_edge, object_id, access_token) :: resp
end
