
import $ from 'jquery';
import CodeMirror from 'codemirror';
import registerElixirMode from 'codemirror-mode-elixir';
import 'codemirror/mode/markdown/markdown';
import 'codemirror/mode/clike/clike';
import 'codemirror/mode/gas/gas';
import 'codemirror/mode/htmlmixed/htmlmixed';
import 'codemirror/mode/javascript/javascript';
import 'codemirror/mode/jsx/jsx';
import 'codemirror/mode/css/css';
import 'codemirror/mode/sass/sass';

let mirror = null;
let current_path = null;
let comments = [];

export function init() {
  let elem = document.getElementById('code-viewer');
  if (!elem) {
    return;
  }
  let opts = {
    readOnly: true,
    lineNumbers: true,
    lineWrapping: true,
  };

  mirror = CodeMirror.fromTextArea(elem, opts);
}

export function viewer_set_file(info) {
  current_path = info.path;
  $('#viewer-file-path').text(current_path);
  mirror.setValue(info.text || "");
  mirror.setOption("mode", info.mode);
  mirror.on("gutterClick", gutter_click);
}

function gutter_click(_cm, line, _class, ev) {
  ev.preventDefault();
  _.debounce(() => {
    create_line_comment(current_path, line)
  }, 100, {leading: true})();
}

function create_line_comment(path, line) {
  console.log("create comment", path, line);
  let body = {

  };
  $.ajax(window.line_comment_path, {
    method: "post",
    dataType: "json",
    contentType: "application/json; charset=UTF-8",
    data: body,
    headers: { "x-csrf-token": window.csrf_token },
    success: () => {

    },
    error: () => {

    }
  });
}

// comments:
//  - addLineWidget
//  -
