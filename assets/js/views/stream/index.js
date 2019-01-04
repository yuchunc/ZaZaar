const mount = () => {
  console.log("Stream Index mounted");
};

const unmount = () => {
  console.log("Stream Index unmounted");
};

export default () => {
  return {
    mount: mount,
    unmount: unmount,
  };
};
