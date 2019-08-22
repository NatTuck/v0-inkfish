
import React from 'react';
import ReactDOM from 'react-dom';
import TreeMenu, {defaultChildren} from 'react-simple-tree-menu';
import {ListGroup, ListGroupItem, Input} from 'reactstrap';
import _ from 'lodash';
import deepFreeze from 'deep-freeze';
import {viewer_set_file} from './code-viewer';

export default function init_view() {
  let root = document.getElementById('code-file-tree');
  if (root) {
    ReactDOM.render(<FileTree data={window.code_view_data} />, root);
  }
}

class FileTree extends React.Component {
  constructor(props) {
    super(props);

    let dirs = list_dirs(props.data.files);

    this.state = deepFreeze({
      sub_id: props.data.sub_id,
      grade_id: props.data.grade_id,
      files: props.data.files,
      active: "[root]",
      dirs: dirs,
    });
  }

  pick_file(ev, props) {
    ev.preventDefault();
    viewer_set_file(props);
    this.setState(deepFreeze({
      ...this.state,
      active: props.path,
    }));
  }

  render() {
    return (
      <TreeMenu
        data={[this.state.files]}
        onClickItem={({...props}) => this.pick_file(props)}
        debounceTime={5}
        initialOpenNodes={this.state.dirs}>
      {({_search, items}) => (
        <ListGroup>
        {items.map((props) => {
          return <ListItem {...props} active={props.label == this.state.active}
                           onClickLabel={(ev) => this.pick_file(ev, props)}/>;
        })}
        </ListGroup>
      )}
      </TreeMenu>
    );
  }
}

function list_dirs(data) {
  if (data.type != "directory") {
    return [];
  }

  let ys = [data.key];

  for (let node of data.nodes) {
    ys = _.concat(ys, list_dirs(node));
  }

  return ys;
}

function ListItem(props) {
  if (props.hasNodes) {
    return <DirListItem {...props} />;
  }

  return (
    <ListGroupItem active={props.active}>
      <span className="tree-toggle">&nbsp;</span>
      <a href="#" onClick={props.onClickLabel}>
        {props.label}
      </a>
    </ListGroupItem>
  );
}

function DirListItem(props) {
  let toggle = (ev) => {
    ev.preventDefault();
    props.hasNodes && props.toggleNode && props.toggleNode()
  };

  return (
    //<ListGroupItem className="d-flex justify-content-between align-items-center">
    <ListGroupItem active={props.active}>
      <span className="tree-toggle">
        <a href="#"
           onClick={toggle}>
          {props.isOpen ? "-" : "+" }
        </a>
      </span>
      <a href="#" onClick={toggle}>
        {props.label}
      </a>
    </ListGroupItem>
  );
}
