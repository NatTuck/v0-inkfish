
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

export function init() {
  let elem = document.getElementById('code-viewer');
  if (!elem) {
    return;
  }
  let opts = {
    readOnly: true,
    lineNumbers: true,
  };

  mirror = CodeMirror.fromTextArea(elem, opts);
}

export function viewer_set_file(info) {
  $('#viewer-file-path').text(info.path);
  mirror.setValue(info.text || "");
  mirror.setOption("mode", info.mode);
}
