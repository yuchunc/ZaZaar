import socket from '../../socket';

const publishComment = (channel) => {
  let commentInput = document.getElementById("comment-input");

  commentInput.addEventListener("keydown", (e) => {
    if(e.keyCode == 13) {
      e.preventDefault();
      let message = commentInput.value.trim();

      if(e.shiftKey) {
        commentInput.value += "\n";
        console.log("shift", commentInput.value);
      } else if(message != "") {
        let payload = {object_id: window.appConfig.videoObjId, message: message};
        console.log("channel", channel);
        channel.push("comment:save", payload)

        console.log("submit", message);
        commentInput.value = "";
      };
    }
  });
};

const appendComment = (channel) => {
  // Appends comments from channel
};

const mount = () => {
  let pageChannel = socket.channel('page:' + window.appConfig.pageObjId, {pageToken: window.appConfig.pageToken});
  pageChannel.join();

  publishComment(pageChannel);

  appendComment(pageChannel);

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
