
import $ from 'jquery';
import _ from 'lodash';
import socket from "./socket";

function join_channel(topic) {
  let channel = socket.channel("search:" + topic, {});
  channel.join()
         .receive("ok", resp => { console.log("Joined successfully", resp); })
         .receive("error", resp => { console.log("Unable to join", resp); });

  return channel;
}

function setup_fields() {
  $('.autosearch').each((ii, field) => {
    field = $(field);

    field.data('search-id', ii);
    let list_id = "suggestions-" + ii;
    let datalist = $(`<datalist id="${list_id}" />`);
    field.after(datalist);
    field.attr("list", list_id);

    let topic = field.data('topic');
    let channel = join_channel(topic);

    let got_matches = (matches) => {
      datalist.empty();
      _.each(matches, (name) => {
        datalist.append(`<option value="${name}" />`);
      });
    };

    let update_suggestions = (ev) => {
      channel.push("q", field.val())
             .receive("ok", ({matches}) => got_matches(matches));
    };

    field.keyup(_.throttle(update_suggestions, 500));
  });
}

$(setup_fields);
