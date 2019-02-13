import socket from '../../socket';
import {el} from "../../utils/dom_control"

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


const tbodyOnclickHandler = (e) => {
  let elem = e.target
  let editables = elem.closest("tr").getElementsByClassName("editable");

  if(elem.classList.contains("merch-snapshot")) {
    event.preventDefault();
    merchSnapshotModal.getElementsByTagName("img")[0].src = elem.src;
    merchSnapshotModal.classList.add("is-active");
  } else if(elem.classList.contains('edit-merch')) {
    event.preventDefault();
    for(let td of editables) {
      if(td.classList.contains("merch-actions")) {
        let editBtn = td.getElementsByClassName("edit-merch")[0];
        let saveBtn = el(`<a class="button is-primary is-outlined save-merch">確認</a>`);
        editBtn.replaceWith(saveBtn);
      } else {
        replaceInnerWithInput(td);
      }
    };
  } else if(elem.classList.contains('save-merch')) {
    event.preventDefault();
    // TODO Websocket send update to server, and success

    for(let td of editables) {
      if(td.classList.contains("merch-actions")) {
        let saveBtn = td.getElementsByClassName("save-merch")[0];
        let editBtn = el(`<a class="button is-primary is-outlined edit-merch">編輯</a>`)

        saveBtn.replaceWith(editBtn);
      } else {
        replaceInputWithText(td);
      }
    }
    // TODO Websocket the update to server, and failed
    // Flashes error message
  };
};

const replaceInnerWithInput = (td) => {
  td.innerHTML = `<input class="input" type="text" value="${td.innerHTML}">`;
};

const replaceInputWithText = (td) => {
  td.innerText = td.children[0].value;
};

const closePreviewModal = () => {
  merchSnapshotModal.getElementsByTagName("img")[0].src = "#"
  merchSnapshotModal.classList.remove('is-active');
}

const mount = () => {
  window.commentsListDom = document.querySelector(".card-content.comments");
  window.closeNewMerchModal = closeNewMerchModal;

  // NOTE probably need to remove this
  let tbody = document.getElementById("items-table-body");
  tbody.addEventListener('click', tbodyOnclickHandler);
  merchSnapshotModal.onclick = closePreviewModal;

  prepCommentsList();

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
