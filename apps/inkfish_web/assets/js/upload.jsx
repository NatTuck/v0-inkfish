import React, { useState } from 'react';
import ReactDOM from 'react-dom';
import { Nav, NavItem, NavLink, TabPane, TabContent, Card, Button, Alert } from 'reactstrap';
import classnames from 'classnames';
import { useDropzone } from 'react-dropzone';
import filesize from 'filesize';

import * as ajax from './ajax';

export default function init_upload(root_id, input_id) {
  let root = document.getElementById(root_id);
  if (root) {
    function gotUploadId(uuid) {
      let input = document.getElementById(input_id);
      input.value = uuid;
    }
    ReactDOM.render(<Upload allowGit={true} allowFile={true}
                            gotUploadId={gotUploadId} />, root);
  }
}

function Upload({allowGit, allowFile, gotUploadId}) {
  let useTabs = allowGit && allowFile;
  let state0 = 'file';
  if (!useTabs && allowGit) {
    state0 = 'git';
  }
  const [tab, setTab] = useState(state0);

  return (
    <div>
      <Tabs useTabs={useTabs} activeTab={tab} setTab={setTab} />
      <TabContent activeTab={tab}>
        <TabPane tabId="file">
          <FileTab gotUploadId={gotUploadId} />
        </TabPane>
        <TabPane tabId="git">
          <GitTab gotUploadId={gotUploadId} />
        </TabPane>
      </TabContent>
    </div>
  );
}

function Tabs({useTabs, activeTab, setTab}) {
  if (!useTabs) {
    return (<div />);
  }

  return (
    <div>
      <Nav tabs>
        <NavItem>
          <NavLink className={classnames({ active: activeTab == 'file' })}
                   onClick={() => setTab('file')} >
            Upload File
          </NavLink>
        </NavItem>
        <NavItem>
          <NavLink className={classnames({ active: activeTab == 'git' })}
                   onClick={() => setTab('git')} >
            Clone Git Repo
          </NavLink>
        </NavItem>
      </Nav>
    </div>
  );
}

function FileTab(props) {
  let [errorMsg, setErrorMsg] = useState(null);

  const {getRootProps, getInputProps, open, acceptedFiles} = useDropzone({
    noClick: true,
    noKeyboard: true,
    multiple: false,
  });

  function upload(ev, file) {
    ev.preventDefault();
    try {
      ajax.upload_file(file, "sub")
          .then((resp) => {
            props.gotUploadId(resp.id);
            setErrorMsg(null);
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
        <Alert variant="danger">
          <span>{errorMsg}</span>
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
        <p>Drop files here, or click browse.</p>
        <Button color="secondary" onClick={open}>
          Browse
        </Button>
      </div>
      <FileInfo />
    </Card>
  );
}

function GitTab(props) {
  return (
    <Card body>
      <p>Git Tab</p>
    </Card>
  );
}
