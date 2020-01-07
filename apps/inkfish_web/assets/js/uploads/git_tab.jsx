import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom';
import { Card, Button, Alert, Row, Col, Label, Input } from 'reactstrap';
import classnames from 'classnames';

import * as ajax from '../ajax';
import * as history from '../console/history';
import Console from '../console/console';

export default function GitTab({gotUpload, token, nonce}) {
  const [url, setUrl] = useState("");
  const topic = "clone:"+nonce;
 
  function startClone() {
    history.done_hook(topic, (msg) => {
      console.log("done callback", msg);
      gotUpload(msg.upload);
    });
    history.push(topic, "clone", {url});
  }

  return (
    <Card body>
      <Row>
        <Col sm={2}>
          <Label for="git-repo-url" className="col-form-label">Repo&nbsp;URL:</Label>
        </Col>
        <Col sm={8} className="form-group">
          <Input type="text" value={url} onChange={(ev) => setUrl(ev.target.value)}
                 id="git-repo-url"
                 placeholder="https://github.com/YourName/repo.git" />
        </Col>
        <Col sm={2}>
          <Button color="secondary" onClick={startClone}>Clone Repo</Button>
        </Col>
      </Row>
      <Row>
        <Console topic={topic} className="clone-console" />
      </Row>
    </Card>
  );
}
