defmodule ZaZaar.FbApiMock do
  @behaviour ZaZaar.Fb.ApiBehaviour

  def me(_, _), do: {:error, %{}}

  def get_object_edge(_, _, _, _), do: {:error, %{}}

  def get_edge_objects(_, _, _, _), do: {:error, %{}}
end
