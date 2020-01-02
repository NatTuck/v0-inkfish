import React, { useState } from 'react';
import ReactDOM from 'react-dom';
import { Nav, NavItem, NavLink, TabPane,
         TabContent, Card, Button, Alert } from 'reactstrap';
import classnames from 'classnames';

import FileTab from './file_tab';
import GitTab from './git_tab';
import * as history from '../console/history';

export default function init_upload(root_id) {
  let root = document.getElementById(root_id);
  if (root) {
    let topic = "clone:" + root.dataset.nonce;
    history.join(topic, root.dataset.token);

    function gotUploadId(uuid) {
      let input = document.getElementById(root.dataset.uploadField);
      input.value = uuid;
    }

    ReactDOM.render(<Upload allowGit={true} allowFile={true}
                            token={root.dataset.token} nonce={root.dataset.nonce}
                            gotUploadId={gotUploadId} />, root);
  }
}

function Upload({allowGit, allowFile, gotUploadId, token, nonce}) {
  let useTabs = allowGit && allowFile;
  if (!useTabs && allowGit) {
    state0 = 'git';
  }
  const [upload, setUpload] = useState(null);

  function gotUpload(upload) {
    gotUploadId(upload.id);
    setUpload(upload);
  }

  function clearUpload() {
    gotUploadId(null);
    setUpload(null);
  }

  return (
    <div>
      <UploadInfo upload={upload} clearUpload={clearUpload} />
      <UploadForms useTabs={useTabs} upload={upload} gotUpload={gotUpload}
                   token={token} nonce={nonce} />
    </div>
  );
}

function UploadInfo({upload, clearUpload}) {
  if (!upload) {
    return <div />;
  }

  function clear(ev) {
    ev.preventDefault();
    clearUpload();
  }

  return (
    <Card body>
      <p>
        <b>Selected File</b>: {upload.name} &nbsp;
        <Button color="danger" onClick={clear}>
          Remove
        </Button>
      </p>
    </Card>
  );
}

function UploadForms({useTabs, upload, gotUpload, token, nonce}) {
  if (upload) {
    return <div/>;
  }

  let tab0 = 'file';
  const [tab, setTab] = useState(tab0);

  return (
    <div>
      <Tabs useTabs={useTabs} activeTab={tab} setTab={setTab} />
      <TabContent activeTab={tab}>
        <TabPane tabId="file">
          <FileTab gotUpload={gotUpload} token={token} />
        </TabPane>
        <TabPane tabId="git">
          <GitTab gotUpload={gotUpload} token={token} nonce={nonce} />
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
                   onClick={() => setTab('file')} href="#">
            Upload File
          </NavLink>
        </NavItem>
        <NavItem>
          <NavLink className={classnames({ active: activeTab == 'git' })}
                   onClick={() => setTab('git')} href="#">
            Clone Git Repo
          </NavLink>
        </NavItem>
      </Nav>
    </div>
  );
}


