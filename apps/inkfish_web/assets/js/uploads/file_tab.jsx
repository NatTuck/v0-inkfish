import React, { useState } from 'react';
import ReactDOM from 'react-dom';
import { Card, Button, Alert } from 'reactstrap';
import { useDropzone } from 'react-dropzone';
import filesize from 'filesize';
import classnames from 'classnames';

import * as ajax from '../ajax';

export default function FileTab({gotUpload, token}) {
  let [errorMsg, setErrorMsg] = useState(null);

  const {getRootProps, getInputProps, open, acceptedFiles} = useDropzone({
    noClick: true,
    noKeyboard: true,
    multiple: false,
  });

  function upload(ev, file) {
    ev.preventDefault();
    try {
      ajax.upload_file(file, token)
          .then((resp) => {
            if (resp.id) {
              gotUpload(resp);
            }
            if (resp.error) {
              setErrorMsg(resp.error);
            }
          });
    }
    catch (ee) {
      setErrorMsg(ee);
    }
  }

  function FileInfo(_props) {
    if (acceptedFiles.length == 0) {
      return (<div/>);
    }

    let errorAlert = null;
    if (errorMsg) {
      console.log(errorMsg);
      errorAlert = (
        <Alert color="danger">
          <b>Error:</b> <span>{errorMsg}</span>
        </Alert>
      );
    }

    let file = acceptedFiles[0];
    return (
      <Card body>
        {errorAlert}
        <p><b>File:</b> {file.path} - {filesize(file.size, {round: 0})}</p>
        <p>
          <Button color="info" onClick={(ev) => upload(ev, file)}>
            Upload File
          </Button>
        </p>
      </Card>
    );
  }

  return (
    <Card body>
      <div {...getRootProps({className: 'dropzone'})}>
        <input {...getInputProps()} />
        <p>Drop files here or click browse.</p>
        <Button color="secondary" onClick={open}>
          Browse
        </Button>
      </div>
      <FileInfo />
    </Card>
  );
}
