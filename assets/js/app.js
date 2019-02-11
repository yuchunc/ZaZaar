// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import loadView from './views/loader';

function handleDOMContentLoaded() {
  const viewName = document.getElementsByTagName('body')[0].dataset.jsViewPath;
  const view = loadView(viewName);

  view.mount();

  window.currentView = view;
}

function handleDocumentUnload() {
  window.currentView.unmount();
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
window.addEventListener('unload', handleDocumentUnload, false);

