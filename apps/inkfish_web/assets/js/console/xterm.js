import React, { useState, useEffect } from 'react';
import { Terminal } from 'xterm';
import { FitAddon } from 'xterm-addon-fit';

export default function Console(props) {
  const cref = React.createRef();
  const [data, setData] = useState(props.data || []);

  console.log("render");

  useEffect(() => {
    const term = new Terminal({
      disableStdin: true,
      fontFamily: "DejaVu Sans Mono",
      fontSize: 14,
    });
    const fit = new FitAddon();
    term.loadAddon(fit);
    term.open(cref.current);
    const dims = fit.proposeDimensions();
    if (dims.cols) {
      fit.fit();
    }

    for (const item of data) {
      term.write(item);
    }

    return (() => term.dispose());
  }, []);

  return (
    <div className="clearfix">
      <div ref={cref} />
    </div>
  );
}
