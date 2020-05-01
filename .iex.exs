import_if_available(ZaZaar.Factory)
import_if_available(Ecto.Query)

alias ZaZaar.Repo

require ZaZaarWeb
ZaZaarWeb.aliases()

alias ZaZaar.Booking.{Order, Buyer}

user = User |> Repo.one()
