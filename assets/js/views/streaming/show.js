//import socket from '../../socket';
import {el} from "../../utils/dom_control"

import "phoenix_html"
import LiveSocket from "phoenix_live_view"

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

const appendCommentPanel = (htmlStr) => {
  let elem = el(htmlStr);

  commentsListDom.appendChild(elem);
  document.getElementById("comment-input").value = "";
  if (commentsListDom.scrollTop >= commentsListDom.scrollHeight - 800) {
   commentsListDom.scrollTop = commentsListDom.scrollHeight;
  }
};

const closeNewMerchModal = (actionFlag) => {
  let merchModal = document.getElementById("merch-modal");
  document.querySelector("html").classList.remove("is-clipped");
  merchModal.classList.remove("is-active");

  merchModal.querySelector("#merch-modal-img").src = "";
  merchModal.querySelector("#merch-modal-username").innerText = "";
  merchModal.querySelector("#merch-modal-message").innerText = '';
  merchModal.querySelector("#merch-modal-title").value = '';
  merchModal.querySelector("#merch-modal-price").value = '';
  merchModal.querySelector("#merch-modal-buyer-id").value = '';
  merchModal.querySelector("#merch-modal-snapshot-url").value = '';

  if (actionFlag === 'newMerch') {
    let merchList = document.querySelector(".streaming__merchandises .card-content");
    console.log("list", merchList);
    merchList.scrollTop = 0;
  };
};

const newMerchandiseModal = (resp) => {
  let merchModal = document.getElementById("merch-modal");

  merchModal.querySelector("#merch-modal-username").innerText = resp.commenterName;
  merchModal.querySelector("#merch-modal-message").innerText = resp.commentMessage;
  merchModal.querySelector("#merch-modal-price").value = /\d+/.exec(resp.commentMessage);
  merchModal.querySelector("#merch-modal-buyer-id").value = resp.commenterId;
  merchModal.querySelector("#merch-modal-buyer-name").value = resp.commenterName;

  document.querySelector("html").classList.add("is-clipped");
  merchModal.classList.add("is-active");
};

const prepCommentsList = () => {
  commentsListDom.scrollTop = commentsListDom.scrollHeight;

  commentsListDom.addEventListener("click", (e) => {
    let elem = e.target
    if (elem.classList.contains("new-merch")) {
      Drab.exec_elixir(`set_merchandise_modal`);
      newMerchandiseModal(elem.dataset);
    };
  });
};

const mount = () => {
  let Hooks = {}
  Hooks.COMMENT_LIST = {
    mounted() {
      const elem = this.el
      elem.scrollTop = elem.scrollHeight
    },
    updated() {
      const elem = this.el
      elem.scrollTop = elem.scrollHeight
    }
  }

  const liveSocket = new LiveSocket("/live", {hooks: Hooks})
  liveSocket.connect()

  console.log("Streaming show mounted");
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
