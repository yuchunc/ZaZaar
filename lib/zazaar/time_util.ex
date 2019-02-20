defmodule ZaZaar.TimeUtil do
  use Timex

  def convert_local_dt(%NaiveDateTime{} = ndt, tz) do
    {:ok, utc_dt} = DateTime.from_naive(ndt, "Etc/UTC")
    if tz == "Etc/UTC", do: utc_dt, else: convert_local_dt(utc_dt, tz)
  end

  def convert_local_dt(dt, tz) do
    Timezone.convert(dt, tz)
  end
end
