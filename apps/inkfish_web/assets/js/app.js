// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss";


// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies

import "phoenix_html";
import jQuery from 'jquery';
window.$ = jQuery;
window.jQuery = jQuery;
import "bootstrap/dist/js/bootstrap.bundle";
import "bootstrap4-toggle";


// Import local files
//
// Local files can be imported directly using relative paths, for example:
import socket from "./socket";
import "./search";
import "./uploads";
import "./graders/number-input";
import "./code-view/init";

$(() => {
  $('.toggle').bootstrapToggle();
});
