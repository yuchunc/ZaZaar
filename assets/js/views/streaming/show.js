import socket from '../../socket';
import {el} from "../../utils/dom_control"

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
  let commentsListDom = document.getElementById("streaming-comments-list");
  commentsListDom.scrollTop = commentsListDom.scrollHeight;

  window.el = el;

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
