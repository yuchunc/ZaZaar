import main from '../main';

let merchSnapshotModal = document.getElementById("merch-snapshot-modal");

const tbodyOnclickHandler = (e) => {
  let elem = e.target

  if(elem.classList.contains("merch-snapshot")) {
    event.preventDefault();
    merchSnapshotModal.getElementsByTagName("img")[0].src = elem.src;
    merchSnapshotModal.classList.add("is-active");
  } else if(elem.classList.contains('edit-merch')) {
    event.preventDefault();
    let editables = elem.closest("tr").getElementsByClassName("editable");
    for(let td of editables) {
      if(td.classList.contains("merch-actions")) {
        console.log("td", td);
        let editBtn = td.getElementsByClassName("edit-merch")[0];
        let saveBtn = el(`<a class="button is-success is-outlined">儲存</a>`);

        editBtn.replaceWith(saveBtn);
      } else {
        replaceInnerWithInput(td);
      }
    };
  };
};

const replaceInnerWithInput = (td) => {
  td.innerHTML = `<input class="input" type="text" value="${td.innerHTML}">`;
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
