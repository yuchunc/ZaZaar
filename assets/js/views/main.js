export default () => {
  return {
    handleError: (error) => {
      if (error) {
        console.log(error);
      }
    },

    mount: () => {
      // This will be executed when the document loads...
      console.log('MainView mounted');
    },

    unmount: () => {
      // This will be executed when the document unloads...
      console.log('MainView unmounted');
    }
  }
};
