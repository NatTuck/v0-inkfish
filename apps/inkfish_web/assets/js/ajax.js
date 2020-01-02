
import { readAsArrayBuffer } from 'promise-file-reader';

export async function get(path) {
  let resp = await fetch('/ajax' + path, {
    method: 'get',
    credentials: 'same-origin',
    headers: new Headers({
      'x-csrf-token': window.csrf_token,
      'content-type': "application/json; charset=UTF-8",
      'accept': 'application/json',
    }),
  });
  return resp.json;
}

export async function post(path, body) {
  let resp = await fetch('/ajax' + path, {
    method: 'post',
    credentials: 'same-origin',
    headers: new Headers({
      'x-csrf-token': window.csrf_token,
      'content-type': "application/json; charset=UTF-8",
      'accept': 'application/json',
    }),
    body: JSON.stringify(body),
  });
  return resp.json();
}

export async function upload_file(file, token) {
  let body = new FormData();
  body.append("upload[token]", token);
  body.append("upload[upload]", file);
  let resp = await fetch('/ajax/uploads', {
    method: 'post',
    credentials: 'same-origin',
    headers: new Headers({
      'x-csrf-token': window.csrf_token,
      'accept': 'application/json',
    }),
    body: body,
  });
  return resp.json();
}
