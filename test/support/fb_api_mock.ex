defmodule ZaZaar.FbApiMock do
  @behaviour ZaZaar.Fb.ApiBehaviour

  def me(_, _), do: {:error, %{}}
end
