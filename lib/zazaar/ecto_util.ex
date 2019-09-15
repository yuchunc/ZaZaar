defmodule ZaZaar.EctoUtil do
  import Ecto.Query

  # @opts [:get_count]

  def get_many_query(query, attrs, opts \\ []) do
    query
    |> apply_filter(attrs)
    |> apply_opts(opts)
  end

  defp apply_filter(query, attrs) when is_map(attrs),
    do: apply_filter(query, Enum.into(attrs, []))

  defp apply_filter(query, []), do: query

  defp apply_filter(query, [{k, v} | t]) when is_list(v) do
    query
    |> where([r], field(r, ^k) in ^v)
    |> apply_filter(t)
  end

  defp apply_filter(query, [{k, v} | t]) do
    query
    |> where([r], field(r, ^k) == ^v)
    |> apply_filter(t)
  end

  defp apply_opts(query, []), do: query

  defp apply_opts(query, [{:get_count, true} | t]) do
    query |> select(count()) |> apply_opts(t)
  end

  defp apply_opts(query, [_ | t]), do: apply_opts(query, t)
end
