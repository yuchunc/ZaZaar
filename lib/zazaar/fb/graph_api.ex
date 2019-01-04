defmodule ZaZaar.Fb.GraphApi do
  @moduledoc false

  use HTTPoison.Base

  alias Facebook.Config

  def process_request_options(options) do
    updated_options =
      case Application.fetch_env(:facebook, :request_conn_timeout) do
        :error -> options
        val -> options ++ [timeout: val]
      end

    case Application.fetch_env(:facebook, :request_recv_timeout) do
      :error -> updated_options
      val -> updated_options ++ [recv_timeout: val]
    end
  end

  def process_url(url), do: url

  def process_response_body(body) do
    body
    |> JSON.decode()
  end
end
