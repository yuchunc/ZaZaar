defmodule ZaZaar.Context do
  @moduledoc """
  DRY boilerplate setup in context
  """

  defmacro __using__(_) do
    quote do
      import Ecto.Query

      require Logger

      alias ZaZaar.Repo
    end
  end
end
