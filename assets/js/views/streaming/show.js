import socket from '../../socket';

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
    console.log("resp", resp);
  });
};

const mount = () => {
  let pageChannel = socket.channel('page:' + window.appConfig.pageObjId, {pageToken: window.appConfig.pageToken});
  pageChannel.join();

  console.log("channel", pageChannel);

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
