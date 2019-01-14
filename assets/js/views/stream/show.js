let merchSnapshotModal = document.getElementById("merch-snapshot-modal");

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

const el = ( domstring ) => {
    const html = new DOMParser().parseFromString( domstring , 'text/html');
    return html.body.firstChild;
};

const closeModal = () => {
  merchSnapshotModal.getElementsByTagName("img")[0].src = "#"
  merchSnapshotModal.classList.remove('is-active');
}

const mount = () => {
  let tbody = document.getElementById("items-table-body");

  tbody.addEventListener('click', tbodyOnclickHandler);

  merchSnapshotModal.onclick = closeModal;

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
