import main from '../main';

let merchSnapshotModal = document.getElementById("merch-snapshot-modal");

const tbodyOnclick = (e) => {
  let elem = e.target

  if(elem.classList.contains("merch-snapshot")) {
    event.preventDefault();
    merchSnapshotModal.getElementsByTagName("img")[0].src = elem.src;
    merchSnapshotModal.classList.add("is-active");
  };
};

const closeModal = () => {
  merchSnapshotModal.getElementsByTagName("img")[0].src = "#"
  merchSnapshotModal.classList.remove('is-active');
}

const mount = () => {
  let tbody = document.getElementById("items-table-body");

  tbody.addEventListener('click', tbodyOnclick);

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
