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

const closeNewMerchModal = () => {
  document.querySelector("html").classList.remove("is-clipped");
  document.getElementById("merch-modal").classList.remove("is-active");

  merchModal.querySelector("#merch-modal-img").src = "";
  merchModal.querySelector("#merch-modal-username").innerText = "";
  merchModal.querySelector("#merch-modal-message").innerText = '';
  merchModal.querySelector("#merch-modal-title").value = '';
  merchModal.querySelector("#merch-modal-price").value = '';
  merchModal.querySelector("#merch-modal-buyer-id").value = '';
  merchModal.querySelector("#merch-modal-snapshot-url").value = '';
};

const newMerchandiseModal = (resp_str) => {
  let payload = JSON.parse(resp_str)
  let merchModal = document.getElementById("merch-modal");

  console.log("payload", payload);
  merchModal.querySelector("#merch-modal-img").src = payload.snapshot_url;
  merchModal.querySelector("#merch-modal-username").innerText = payload.buyer_name;
  merchModal.querySelector("#merch-modal-message").innerText = payload.message;
  merchModal.querySelector("#merch-modal-title").value = payload.title;
  merchModal.querySelector("#merch-modal-price").value = payload.price;
  merchModal.querySelector("#merch-modal-buyer-id").value = payload.buyer_fb_id;
  merchModal.querySelector("#merch-modal-snapshot-url").value = payload.snapshot_url;

  document.querySelector("html").classList.add("is-clipped");
  merchModal.classList.add("is-active");
  //document.querySelector("main").appendChild(el(modal_str));
};

const mount = () => {
  window.commentsListDom = document.getElementById("streaming-comments-list");
  commentsListDom.scrollTop = commentsListDom.scrollHeight;

  window.el = el;
  window.newMerchandiseModal = newMerchandiseModal;
  window.closeNewMerchModal = closeNewMerchModal;

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
