
import $ from 'jquery';
import 'dm-file-uploader';

function setup() {
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
