defmodule ZaZaarWeb.StreamingCommander do
  use ZaZaarWeb, :commander
  # Place your event handlers here
  #
  # defhandler button_clicked(socket, sender) do
  #   set_prop socket, "#output_div", innerHTML: "Clicked the button!"
  # end
  #
  # Place you callbacks here
  #
  onload(:page_loaded)

  def page_loaded(socket) do
    set_prop(socket, "#streaming-comments-list", innerText: "This page has been drabbed")
  end
end