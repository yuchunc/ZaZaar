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

      <div class="card-content comments" id="streaming-comments-list" phx-hook="COMMENT_LIST">
        <%= for comment <- @comments do %>
          <%= comment_elem(comment: comment, fb_video_id: @fb_video_id) %>
        <% end %>
      </div>

      <footer class="card-footer has-background-light">
        <div class="media">
          <figure class="media-left image is-32x32 is-avatar">
            <img class="is-rounded" src="<%= if @page.picture_url, do: @page.picture_url, else: "https://bulma.io/images/placeholders/30x30.png"%>">
          </figure>
          <form phx-submit="new_comment">
            <div class="media-content">
              <div class="field">
                <div class="control">
                  <input class="input" id="comment-input" name="comment" value="<%= @textarea %>" autocomplete="off" phx-keyup="set_comment"/>
                </div>
              </div>
            </div>
          </form>
        </div>
      </footer>
    </div>
    """

    # <textarea class="input" id="comment-input" name="comment" placeholder="<%= gettext("Comment Here...") %>"><%= @textarea %></textarea>
  end

  def comment_elem(assigns) do
    assigns = Enum.into(assigns, %{})

    ~L"""
    <div class="media comment-panel">
      <figure class="media-left image is-32x32 is-avatar">
        <img class="is-rounded" src=<%= @comment.commenter_picture %>>
      </figure>
      <div class="media-content">
        <div class="content comment has-background-light is-marginless">
          <p>
            <span class="is-username has-text-primary has-text-weight-semibold">
              <%= @comment.commenter_fb_name %>
            </span>
            <%= @comment.message %>
          </p>
        </div>

        <!-- 留言時間 + 手動新增 btn -->
        <div class="level is-mobile">
          <small class="has-text-grey-light">
            15 小時
          </small>
          <button class="button is-small is-outlined has-text-grey is-hover-primary new-merch"
                  phx-click="enable-merch-modal"
                  phx-value-object-id="<%= @comment.object_id %>"
          >
            <%= gettext "New Merch" %>
          </button>
        </div>
      </div>
    </div>
    """
  end

  def mount(session, socket) do
    %{fb_video_id: fb_video_id, comments: comments, page: page} = session
    assigns = %{comments: comments, page: page, textarea: nil, fb_video_id: fb_video_id}

    {:ok, assign(socket, assigns)}
  end

  def handle_event("set_comment", %{"value" => value}, socket) do
    {:noreply, assign(socket, :textarea, value)}
  end

  def handle_event("new_comment", %{"comment" => comment}, socket) do
    send(self(), {:new_comment, comment})
    {:noreply, assign(socket, :textarea, "")}
  end

  def handle_event("enable-merch-modal", params, socket) do
    payload = cast_new_merch(params, socket)
    Phoenix.PubSub.broadcast(ZaZaar.PubSub, "stream:#{payload.fb_video_id}", payload)
    {:noreply, socket}
  end

  def handle_info({:new_comment, new_comment}, socket) do
    %{comments: comments, page: page, fb_video_id: fb_video_id} = socket.assigns

    comments_1 =
      case Fb.publish_comment(fb_video_id, new_comment, page.access_token) do
        {:ok, comment} ->
          comments ++ [comment]

        _ ->
          comments
      end

    {:noreply, assign(socket, comments: comments_1)}
  end

  defp cast_new_merch(raw_params, socket) do
    %{
      source: __MODULE__,
      action: :new_merch,
      fb_video_id: socket.assigns.fb_video_id,
      object_id: raw_params["object-id"]
    }
  end
end
