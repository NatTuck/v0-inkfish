
import $ from 'jquery';
import init_tree from "./file-tree";
import {init as init_code} from "./code-viewer";

$(function() {
  init_tree();
  init_code();
});
