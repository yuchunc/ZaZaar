{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(ZaZaar.Repo, :manual)

Mox.defmock(ZaZaar.FbApiMock, for: ZaZaar.Fb.ApiBehaviour)
