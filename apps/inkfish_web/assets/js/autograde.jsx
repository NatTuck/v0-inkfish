import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom';

import Console from './console/console';
import * as history from './console/history';

export default function init_autograde_logs() {
  for (let root of document.getElementsByClassName('autograde-log')) {
    let {token, topic} = root.dataset;
    history.join(topic, token);
    ReactDOM.render(<AutogradeLog topic={topic} />, root);
  }
}

function AutogradeLog({topic}) {
  return (
    <Console topic={topic} className="autograde-console" />
  );
}
