
import socket from "../socket";

let next_serial = 0;

// Connected channels.
let channels = new Map();

// Subscribed consoles by topic.
let consoles = new Map();

// Done hooks by topic.
let done_hooks = new Map();

// History by topic.
let hist = new Map();


export function join(topic, token, on_join) {
  let chan = socket.channel(topic, {token});
  chan.join()
      .receive("ok", (msg) => {
        console.log("Joined", topic, msg);
        if (on_join) {
          on_join(msg);
        }
      })
      .receive("error", (msg) => {
        console.log("Unable to join", msg);
      });
  chan.on("output", (msg) => on_output(topic, msg));
  chan.on("done", (msg) => on_done(topic, msg));
  channels.set(topic, chan);
}

export function leave(topic) {
  let chan = channels.get(topic);
  if (chan) {
    chan.leave();
    channels.delete(topic);
  }
}

export function done_hook(topic, func) {
  done_hooks.set(topic, func);
}

export function push(topic, tag, msg) {
  let chan = channels.get(topic);
  chan.push(tag, msg);
}

function get_subs(topic) {
  return consoles.get(topic) || new Map();
}

function on_output(topic, msg) {
  let prev = hist.get(topic) || [];
  hist.set(topic, prev.concat([msg]));

  for (const [_key, sub] of get_subs(topic)) {
    sub.posn = msg.serial;
    sub.func(msg);
  }
}

function on_done(topic, msg) {
  console.log("on done called");
  let hook = done_hooks.get(topic);
  if (hook) {
    hook(msg);
  }
}

export function subscribe(topic, func) {
  let posn = 0;
  let past = hist.get(topic) || [];
  past.sort((aa, bb) => {
    return aa.serial <= bb.serial;
  });
  for (const item of past) {
    func(item);
    posn = item.serial;
  }

  const serial = next_serial++;
  let subs = get_subs(topic);
  let sub = {
    func: func,
    posn: posn,
  };
  subs.set(serial, sub);
  consoles.set(topic, subs);

  return function() {
    subs.delete(serial);
  }
}

export function get_history(topic) {
  let past = hist.get(topic) || [];
  past.sort((aa, bb) => {
    return aa.serial - bb.serial;
  });
  past = past.map((item) => item.text);
  return past;
}
