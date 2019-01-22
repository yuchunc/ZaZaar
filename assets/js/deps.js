// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../scss/app.scss"

//import "@fortawesome/fontawesome-free/js/all.js";
import "../fontawesome-pro-5.5.0-web/js/all.js";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

window.__socket = require("phoenix").Socket;
