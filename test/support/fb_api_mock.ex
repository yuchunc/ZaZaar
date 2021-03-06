defmodule ZaZaar.FbApiMock do
  @behaviour ZaZaar.Fb.ApiBehaviour

  def me(_, _), do: {:error, %{}}

  def get_object_edge(_, _, _, _), do: {:error, %{}}

  def get_edge_objects(_, _, _, _), do: {:error, %{}}

  def stream(_), do: []

  def publish(_, _, _, _), do: {:error, :from_api_mock}

  def remove(_, _, _), do: {:error, :from_api_mock}
end
