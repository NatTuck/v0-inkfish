
import _ from 'lodash';
import $ from 'jquery';
import 'dm-file-uploader';
import uuid from 'uuid/v4';

import socket from "./socket";

function setup() {
  if (window.current_page == 'sub/new') {
    //setup_cloner();
  }

  if ($('.upload-drop-area')) {
    setup_uploader();
  }
}

function join_channel(topic) {
  let channel = socket.channel("clone:" + topic, {});
  channel.join()
         .receive("ok", resp => { console.log("Joined successfully", resp); })
         .receive("error", resp => { console.log("Unable to join", resp); });
  return channel;
}

function scroll_down(elem) {
  if (elem.scrollHeight - elem.clientHeight < elem.scrollTop - 5) {
    return;
  }
  elem.scrollTop = elem.scrollHeight - elem.clientHeight;
}

function setup_cloner() {
  let ch_id = uuid();
  let channel = join_channel(ch_id);
  console.log("joined channel: clone:" + ch_id);

  channel.on("print", ({text}) => {
    let msg = text;
    msg = msg.replace(/\r$/, "\n");
    $('#git-output-log').append(msg);
    let scroll_fn = () => {
      scroll_down($('#git-output-log')[0]);
    };
    _.debounce(scroll_fn, 50)();
  });

  channel.on("fail", ({msg}) => {
    $('#git-output-log').append("\nFAIL:\n" + msg);
  });

  channel.on("done", ({upload_id}) => {
    let id_field = $('#git-output-log').data('id-field');
    console.log("done", upload_id);
    $("#" + id_field).val(upload_id);
  });

  $('#git-clone-btn').click((ev) => {
    ev.preventDefault();
    let url = $('#git-clone-input').val();
    channel.push("clone", {url: url});
  });

  console.log("cloner setup done");
}

function setup_uploader() {
  $('.upload-drop-area').each((_, elem) => {
    let ee = $(elem);
    let exts = null;
    if (ee.data('exts')) {
      exts = ee.data('exts').split(',');
    }
    let file;

    var set_progress = (pct) => {
      let bar = $(ee).find('.progress-bar');
      bar.css('width', `${pct}%`);
      bar.text(`${pct}%`);
    };

    var set_message = (text) => {
      console.log("set message: " + text);
      let msg = $(ee).find('.message');
      msg.text(text);
    }

    var clear_upload = (ev) => {
      ev.preventDefault();
      $("#" + ee.data('id-field')).val("");
      console.log("clear upload");
    };

    ee.find('.upload-clear-button').click(clear_upload);

    ee.dmUploader({
      url: window.upload_path,
      fieldName: 'upload[upload]',
      extFilter: exts,
      maxFileSize: 10 * 1024 * 1024,
      multiple: false,
      extraData: {
        'upload[kind]': ee.data('kind'),
      },
      headers: {
        "x-csrf-token": window.csrf_token,
        accept: "application/json; charset=utf-8",
      },
      onNewFile: (_id, new_file) => {
        file = new_file;
        $(ee).find('.progress').show();
        set_progress(0);
      },
      onUploadProgress: (_id, pct) => {
        set_progress(pct);
      },
      onUploadSuccess: (_id, data) => {
        set_progress(100);
        ee.find('.progress').hide();
        set_message(`✓ Upload done: ${file.name}`);
        console.log(data);

        $("#" + ee.data('id-field')).val(data.id);

        if (data.kind == "user_photo") {
          $("#photo-preview").attr('src', data.path);
        }

        ee.find('input').val(null);
      },
      onUploadError: (_id, data) => {
        set_progress(0);
        $(ee).find('.progress').hide();
        let text = data.statusText;
        if (data.responseJSON) {
          text = data.responseJSON.error;
        }
        set_message(`✗ Upload failed: ${file.name}, ${text}`);
        console.log(data);
      },
      onFileExtError: (file) => {
        set_message(`✗ Bad file extension, must be: ${exts}`);
      },
      onFileSizeError: (file) => {
        set_message("✗ File too big");
      },
    });

    console.log("uploader ready");
  });
}

$(setup);
