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
              <form phx-submit="new_comment">
                <div class="media-content">
                  <div class="field">
                    <div class="control">
                      <input class="input" id="comment-input" name="comment" value="<%= @textarea %>" />
                    </div>
                  </div>
                </div>
              </form>
            </div>
          </footer>
        </div>
    """
                      #<textarea class="input" id="comment-input" name="comment"
                          #placeholder="<%= gettext("Comment Here...") %>"><%= @textarea %></textarea>
  end

  def mount(session, socket) do
    %{comments: comments, page: page} = session
    assigns = %{comments: comments, page: page, textarea: nil}

    {:ok, assign(socket, assigns)}
  end

  def handle_event("new_comment", %{"comment" => comment}, socket) do
    {:noreply, assign(socket, :textarea, "")}
  end
end
