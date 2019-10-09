import socket from '../../socket';
import { Socket } from "phoenix"

import "phoenix_html"
import LiveSocket from "phoenix_live_view"

const mount = () => {
  const liveSocket = new LiveSocket("/live", Socket)
  liveSocket.connect()

  console.log("Order index mounted");
};

const unmount = () => {
  console.log("Order index unmounted");
}

export default () => {
  return {
    mount: mount,
    unmount: unmount,
  }
}
