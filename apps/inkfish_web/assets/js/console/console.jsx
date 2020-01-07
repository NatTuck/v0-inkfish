import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom';
import classnames from 'classnames';

import * as history from './history';

let console_count = 0;

function scroll_down(elem) {
  if (elem.scrollHeight - elem.clientHeight < elem.scrollTop - 5) {
    return;
  }
  elem.scrollTop = elem.scrollHeight - elem.clientHeight;
}

export default function Console({topic, className}) {
  // Normalize data to remove stray carriage returns.
  const [posn, setPosn] = useState(0);
  const [elem_id, _] = useState("console-" + (console_count++));

  useEffect(() => {
    return history.subscribe(topic, (item) => {
      setPosn(item.serial);
    });
  }, []);

  useEffect(() => {
    scroll_down(document.getElementById(elem_id));
  });

  let data = history.get_history(topic);
  let text = data.join("").replace(/[^\n]*\r(?!\n)/g, "");

  return (
    <pre className={classnames(className, 'console')} id={elem_id}>
      {text}
    </pre>
  );
}
