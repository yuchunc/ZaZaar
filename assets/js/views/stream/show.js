import socket from '../../socket';
import { Socket } from "phoenix"
import {el} from "../../utils/dom_control"

import "phoenix_html"
import LiveSocket from "phoenix_live_view"

let merchSnapshotModal = document.getElementById("merch-snapshot-modal");

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
  commentsListDom.addEventListener("click", (e) => {
    let elem = e.target
    if (elem.classList.contains("new-merch")) {
      Drab.exec_elixir(`set_merchandise_modal`);
      newMerchandiseModal(elem.dataset);
    };
  });
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
    merchList.scrollTop = merchList.scrollHeight;
  };
};

const closePreviewModal = () => {
  merchSnapshotModal.getElementsByTagName("img")[0].src = "#"
  merchSnapshotModal.classList.remove('is-active');
}

const mount = () => {
  window.commentsListDom = document.querySelector(".card-content.comments");
  window.closeNewMerchModal = closeNewMerchModal;

  merchSnapshotModal.onclick = closePreviewModal;

  const liveSocket = new LiveSocket("/live", Socket)
  liveSocket.connect()

  console.log("Stream show mounted");
};

const unmount = () => {
  console.log("Stream show unmounted");
}

export default () => {
  return {
    mount: mount,
    unmount: unmount,
  }
}
