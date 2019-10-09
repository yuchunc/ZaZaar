defmodule ZaZaarWeb.StreamingLive.CommentArea do
  use ZaZaarWeb, :live

  alias ZaZaar.Account

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
                  <input class="input" id="comment-input" name="comment" value="<%= @textarea %>" autocomplete="off" />
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
    %{video_id: video_id, page_id: page_id} = session

    assigns =
      Map.merge(session, %{
        comments: [],
        page: Account.get_page(page_id),
        textarea: nil
      })

    send(self(), {:mounted, video_id})

    {:ok, assign(socket, assigns)}
  end

  def handle_info({:mounted, video_id}, socket) do
    video = Transcript.get_video(video_id, preload: :comments)

    {:noreply, assign(socket, :comments, video.comments)}
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

  def handle_event("new_comment", %{"comment" => comment0}, socket) do
    %{comments: comments, page: page, fb_video_id: fb_video_id} = socket.assigns

    comments_1 =
      case Fb.publish_comment(fb_video_id, comment0, page.access_token) do
        {:ok, comment1} ->
          comments ++ [comment1]

        _ ->
          comments
      end

    assigns = %{comments: comments_1, textarea: ""}

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("enable-merch-modal", params, socket) do
    payload = cast_new_merch(params, socket)
    %{video_id: video_id} = socket.assigns
    Phoenix.PubSub.broadcast(ZaZaar.PubSub, "stream:#{video_id}", payload)
    {:noreply, socket}
  end

  defp cast_new_merch(raw_params, socket) do
    %{
      source: __MODULE__,
      action: :new_merch,
      has_snapshot: true,
      fb_video_id: socket.assigns.fb_video_id,
      object_id: raw_params["object-id"]
    }
  end
end
