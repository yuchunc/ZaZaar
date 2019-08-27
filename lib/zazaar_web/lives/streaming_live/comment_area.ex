defmodule ZaZaarWeb.StreamingLive.CommentArea do
  use ZaZaarWeb, :live

  def render(assigns) do
    ~L"""
        <div class="tile is-child card">
          <header class="card-header">
            <p class="card-header-title">
              <%= gettext "Live Comments" %>
            </p>
          </header>

          <div class="card-content comments" id="streaming-comments-list">
            <%= for comment <- @comments do %>
              <%= render ZaZaarWeb.StreamView, "comment.html", comment: comment %>
            <% end %>
          </div>

          <footer class="card-footer has-background-light">
            <div class="media">
              <figure class="media-left image is-32x32 is-avatar">
                <img class="is-rounded"
                     src="<%= if @page.picture_url, do: @page.picture_url, else: "https://bulma.io/images/placeholders/30x30.png"%>">
              </figure>
              <div class="media-content">
                <div class="field">
                  <div class="control">
                    <textarea class="input" id="comment-input" type="text" placeholder="<%= gettext("Comment Here...") %>"
                              phx-keyup="new_comment" ></textarea>
                  </div>
                </div>
            </div>
          </footer>
        </div>
    """
  end

  def mount(session, socket) do
    assigns = Map.take(session, [:comments, :page]) |> Map.to_list()

    {:ok, assign(socket, assigns)}
  end
end
