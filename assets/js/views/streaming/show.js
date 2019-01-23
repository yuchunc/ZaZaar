import socket from '../../socket';

const appConfig = window.appConfig;

const shiftEnterAction = () => {
  let commentInput = document.getElementById("comment-input");

  commentInput.addEventListener("keydown", (e) => {
    if(!e.shiftKey && e.keyCode == 13) {
      e.preventDefault();
    } else if (e.shiftKey && e.keyCode == 13) {
      commentInput.value += "\n";
    };
  });
};


const mount = () => {
  window.commentsListDom = document.getElementById("streaming-comments-list");
  window.commentsListDom.scrollTop = window.commentsListDom.scrollHeight;

  shiftEnterAction();

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
