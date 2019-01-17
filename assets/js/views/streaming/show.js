import socket from '../../socket';
import * as R from 'ramda';

const el = ( domstring ) => {
  const html = new DOMParser().parseFromString( domstring , 'text/html');
  return html.body.firstChild;
};

const publishComment = (channel) => {
  let commentInput = document.getElementById("comment-input");

  commentInput.addEventListener("keydown", (e) => {
    if(e.keyCode == 13) {
      e.preventDefault();
      let message = commentInput.value.trim();

      if(e.shiftKey) {
        commentInput.value += "\n";
      } else if(message != "") {
        let payload = {object_id: window.appConfig.videoObjId, message: message};
        channel.push("comment:save", payload)
        commentInput.value = "";
      };
    }
  });
};

const appendComments = (channel) => {
  channel.on("video:new_comments", (resp) => {
    if(resp.video_id === window.appConfig.videoId) {
      let commentsListDom = document.getElementById("streaming-comments-list");
      let currentCommentIds = R.map((elem) => {
        return elem.dataset.objectId;
      }, document.getElementsByClassName("comment-panel"));

      R.forEach((newCom) => {
        if(!R.contains(newCom.object_id, currentCommentIds)) {
          let toBottom = commentsListDom.scrollTop >= (commentsListDom.scrollHeight - 600)
          let newComElem =
            el(`<div class="media comment-panel" data-object-id="${newCom.object_id}">
                  <figure class="media-left image is-32x32 is-avatar">
                    <img class="is-rounded" src="${newCom.commenter_picture}">
                  </figure>
                  <div class="media-content comment has-background-light">
                    <a class="is-username has-text-primary has-text-weight-semibold is-link">
                      ${newCom.commenter_fb_name}
                    </a>
                    ${newCom.message}
                  </div>
                </div>`)

          commentsListDom.appendChild(newComElem);

          console.log(toBottom);
          if(toBottom) {commentsListDom.scrollTop = commentsListDom.scrollHeight};
        };
      }, resp.comments)
    };
  });
};


const mount = () => {
  let commentsListDom = document.getElementById("streaming-comments-list");

  commentsListDom.scrollTop = commentsListDom.scrollHeight;

  let pageChannel = socket.channel('page:' + window.appConfig.pageObjId, {pageToken: window.appConfig.pageToken});
  pageChannel.join();

  publishComment(pageChannel);

  appendComments(pageChannel);

  console.log("Streaming show unmounted");
};

const unmount = () => {
  console.log("Streaming show unmounted");
};

export default () => {
  return {
    mount: mount,
    unmount: unmount,
  }
};
