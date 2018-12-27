defmodule ZaZaar.EctoUtil do
  import Ecto.Query

  def get_many_query(queriable, []), do: queriable

  def get_many_query(queriable, [{k, v} | t]) when is_list(v) do
    queriable
    |> where([r], field(r, ^k) in ^v)
    |> get_many_query(t)
  end

  def get_many_query(queriable, [{k, v} | t]) do
    queriable
    |> where([r], field(r, ^k) == ^v)
    |> get_many_query(t)
  end
end
