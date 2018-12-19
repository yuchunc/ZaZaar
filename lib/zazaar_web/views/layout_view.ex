defmodule ZaZaarWeb.LayoutView do
  use ZaZaarWeb, :view

  @doc """
  Generates path for the JavaScript view we want to use
  in this combination of view/template.
  """
  def js_view_path(conn, view_template) do
    [view_name(conn), template_name(view_template)]
    |> Enum.join("/")
  end

  # Takes the resource name of the view module and removes the
  # the ending *_view* string.
  def view_name(conn) do
    conn
    |> view_module
    |> Phoenix.Naming.resource_name()
    |> String.replace("_view", "")
  end

  # Removes the extion from the template and reutrns
  # just the name.
  def template_name(template) when is_binary(template) do
    template
    |> String.split(".")
    |> Enum.at(0)
  end

  def show_flash(conn) do
    conn
    |> get_flash
    |> Enum.map(&flash_html/1)
  end

  def flash_html({level, message}) do
    {:safe,
     """
     <div class='notification is-#{level}'>
       <button class='delete'></button>
       #{message}
     </div>
     """}
  end

  def flash_html(_), do: nil
end
