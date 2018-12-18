import MainView from './main';

export default (viewPath) => {
  let view;

  try {
    const viewFactory = require('./' + viewPath);
    view = viewFactory.default();
  } catch(e) {
    console.log(e);
    view = Object.create(MainView());
  };

  return view;
}
