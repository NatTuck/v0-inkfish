import React, { useState, useEffect } from 'react';
import { Terminal } from 'xterm';

function Console(props) {
  const cref = React.createRef();
  const [data, setData] = useState([]);

  useEffect(() => {
    const term = new Terminal();
    term.open(cref.current);

    for (const item of data) {
      term.write(item);
    }

    return (() => term.dispose());
  });

  return (
    <div ref={cref} />
  );
}
