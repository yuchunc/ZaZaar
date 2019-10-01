import { Socket } from "phoenix"
import { el } from "../../utils/dom_control"

import "phoenix_html"
import LiveSocket from "phoenix_live_view"

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

  const liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks})
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
