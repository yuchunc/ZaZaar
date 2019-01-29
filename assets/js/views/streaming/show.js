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

const cancelNewMerchandise = () => {
  document.querySelector("html").classList.remove("is-clipped");
  document.getElementById("new-merch-modal").remove();
};

const newMerchandiseModal = (modal_str) => {
  let html = document.querySelector("html");
  html.classList.add("is-clipped");

  document.querySelector("main").appendChild(el(modal_str));
};

const mount = () => {
  window.commentsListDom = document.getElementById("streaming-comments-list");
  commentsListDom.scrollTop = commentsListDom.scrollHeight;

  window.el = el;
  window.newMerchandiseModal = newMerchandiseModal;
  window.cancelNewMerchandise = cancelNewMerchandise;

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
