
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
import feather from 'feather-icons';

let mirror = null;
let current_path = null;
let comments = [];
let grade_callback = null;

// FIXME: Want single source of truth between this
// and the file list.
let grade = null;

function init() {
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
  grade = window.code_view_data.grade;

  if (window.code_view_data.edit) {
    mirror.on("gutterClick", gutter_click);
  }

  show_line_comments();
}

function set_file(info) {
  current_path = info.path;
  let path = window.upload_unpacked_base + "/" + current_path;
  let icon = feather.icons["download"].toSvg();
  let link = `${current_path} <a href="${path}">${icon}</a>`;
  $('#viewer-file-path').html(link);
  mirror.setValue(info.text || "");
  mirror.setOption("mode", info.mode);

  show_line_comments();
}

function set_grade_callback(cb) {
  grade_callback = cb;
}

let viewer = { init, set_file, set_grade_callback };
export default viewer;

function line_comment_color(points) {
  let colors = "bg-secondary";
  if (points > 0) {
    colors = "bg-success text-white";
  }
  if (points < 0) {
    colors = "bg-warning";
  }
  return colors;
}

function show_line_comments() {
  _.each(comments, (item) => item.node.clear());
  comments = [];

  if (grade) {
    let xs = grade.line_comments;
    _.each(xs, show_line_comment);
  }
}

function show_line_comment(data) {
  if (data.path != current_path) {
    return;
  }

  if (window.code_view_data.edit) {
    show_line_comment_edit(data);
  }
  else {
    show_line_comment_view(data);
  }
}

function show_line_comment_view(data) {
  let color = line_comment_color(data.points);

  let card_id = "lc-" + data.id;
  let points = +data.points;
  if (points >= 0) {
    points = `+${points}`;
  }

  let html = `
  <div class="card comment-card" id="${card_id}">
    <div class="card-body">
      <span class="badge ${color}">
        ${points}
      </span>
      ${data.text}
      (${data.user.name})
    </div>
  </div>
  `;

  let lc = document.createElement("div");
  lc.innerHTML = html;

  let node = mirror.addLineWidget(data.line, lc, {above: true});
  comments.push({id: data.id, node: node, lc: lc});
}

function show_line_comment_edit(data) {
  let color = line_comment_color(data.points);
 
  let card_id = "lc-" + data.id;
  let num_id  = card_id + "-num";
  let body_id = card_id + "-body";
  let text_id = card_id + "-text";

  let alert_icon = feather.icons['alert-triangle'].toSvg({color: 'white'});
  let check_icon = feather.icons['check'].toSvg({color: 'white'});

  let html = `
  <div class="card comment-card" id="${card_id}" data-comment-id="${data.id}">
    <div class="card-body ${color}" id="${body_id}">
      <div class="row">
        <div class="col-9">
          <p>Grader: ${data.user.name}</p>
        </div>
        <div class="col-3 text-right">
          <span class="save-done" style="display: none;">
            ${check_icon}
          </span>
          <span class="save-fail" style="display: none;">
            ${alert_icon}
          </span>
          <button class="btn btn-success btn-sm save-button" disabled>
            <i data-feather="save"></i>
          </button>
          <button class="btn btn-danger btn-sm kill-button">
            <i data-feather="trash"></i>
          </button>
        </div>
      </div>
      <div class="row">
        <div class="col-2">
          <input id="${num_id}" class="form-control" type="number"
                 value="${data.points}" />
        </div>
        <div class="col-10">
          <textarea id="${text_id}" class="form-control"
                    rows="3">${data.text}</textarea>
        </div>
      </div>
    </div>
  </div>
  `;

  let lc = document.createElement("div");
  lc.innerHTML = html;

  let node = mirror.addLineWidget(data.line, lc, {above: true});
  comments.push({id: data.id, node: node, lc: lc});

  $(lc).find('input').change(comment_score_changed);
  $(lc).find('textarea').change(comment_changed);
  $(lc).find('textarea').keyup(comment_changed);
  $(lc).find('.save-button').click(save_comment);
  $(lc).find('.kill-button').click(kill_comment);

  feather.replace();
}

function comment_score_changed(ev) {
  ev.preventDefault();
  let tgt = ev.target;
  let score = +tgt.value;
  let color = line_comment_color(score);
  let body = $(tgt).closest('div.card-body');
  body.attr('class', 'card-body ' + color);
  comment_changed(ev);
}

function comment_changed(ev) {
  ev.preventDefault();
  let tgt = ev.target;
  let body = $(tgt).closest('div.card-body');
  body.find('.save-button').removeAttr("disabled");
  body.find('.save-done').hide();
  body.find('.save-fail').hide();
}

function save_comment(ev) {
  ev.preventDefault();
  let tgt = ev.target;
  let card = $(tgt).closest('div.card');
  let id = +card.data('comment-id');
  let points = card.find('input').val();
  let text = card.find('textarea').val();

  let body = {
    line_comment: {
      points: points,
      text: text,
    }
  }

  let path = window.line_comment_paths.update.replace("ID", id);
  $.ajax(path, {
    method: "patch",
    dataType: "json",
    contentType: "application/json; charset=UTF-8",
    headers: { "x-csrf-token": window.csrf_token },
    data: JSON.stringify(body),
    success: (data, status) => {
      data = data.data;

      if (grade_callback && data.grade) {
        grade = data.grade;
        grade_callback(data.grade);
      }

      console.log(status, data);
      card.find('.save-button').attr('disabled', true);
      card.find('.save-done').show();
      card.find('.save-fail').hide();
    },
    error: (xhr, status) => {
      console.log(status, xhr);
      let fail = card.find('.save-fail');
      fail.show();
      fail.attr('title', status);
      fail.tooltip();
      card.find('.save-done').hide();
    }
  });
}

function kill_comment(ev) {
  ev.preventDefault();
  let tgt  = ev.target;
  let card = $(tgt).closest('div.card');
  let id   = +card.data('comment-id');

  let path = window.line_comment_paths.update.replace("ID", id);
  $.ajax(path, {
    method: "delete",
    dataType: "json",
    contentType: "application/json; charset=UTF-8",
    headers: { "x-csrf-token": window.csrf_token },
    data: "",
    success: (data, status) => {
      data = data.data;

      if (grade_callback && data.grade) {
        grade = data.grade;
        grade_callback(data.grade);
      }

      for (let ii = 0; ii < comments.length; ++ii) {
        let item = comments[ii];
        if (item.id == id) {
          // clear can fail in ajax callback, so we delay it
          let del_fn = () => {
            comments.splice(ii, 1);
            $(item.lc).hide();
            // FIXME: clear() sometimes throws:
            //  << Permission denied to access property "nodeType" >>
            // This leaks a DOM node.
            // Why?
            item.node.clear();
          };
          setTimeout(del_fn, 0);
          break;
        }
      }
    },
    error: (xhr, status) => {
      console.log(status, xhr);
      let fail = card.find('.save-fail');
      fail.show();
      fail.attr('title', status);
      fail.tooltip();
      card.find('.save-done').hide();
    }
  });
}

function gutter_click(_cm, line, _class, ev) {
  ev.preventDefault();
  _.debounce(() => {
    create_comment(current_path, line)
  }, 100, {leading: true})();
}

function create_comment(path, line) {
  console.log("create comment", path, line);
  let body = {
    line_comment: {
      grade_id: window.code_view_data.grade_id,
      path: path,
      line: line,
      text: "",
      points: "0",
    },
  };
  $.ajax(window.line_comment_paths.create, {
    method: "post",
    dataType: "json",
    contentType: "application/json; charset=UTF-8",
    data: JSON.stringify(body),
    headers: { "x-csrf-token": window.csrf_token },
    success: (data, status) => {
      data = data.data;

      console.log("created", data);
      if (grade_callback && data.grade) {
        grade = data.grade;
        grade_callback(data.grade);
      }

      window.setTimeout(() => show_line_comment(data), 0);
    },
    error: (xhr, status) => {
      console.log(status, xhr);
    }
  });
}
