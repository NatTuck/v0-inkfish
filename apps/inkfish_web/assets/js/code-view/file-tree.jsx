
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

    this.state = deepFreeze({
      sub_id: props.data.sub_id,
      grade_id: props.data.grade_id,
      files: props.data.files,
      active: "[root]",
    });
  }

  pick_file(ev, props) {
    ev.preventDefault();
    console.log("props:", props);
    viewer_set_file(props);
  }

  render() {
    return (
      <TreeMenu
        data={[this.state.files]}
        onClickItem={({...props}) => this.pick_file(props)}
        debounceTime={5}
        initialOpenNodes={[""]}>
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

function ListItem(props) {
  let toggle = <span className="tree-toggle">&nbsp;</span>;
  if (props.hasNodes) {
    toggle = (
      <span className="tree-toggle">
        <a href="#"
           onClick={(ev) => {
             ev.preventDefault();
             props.hasNodes && props.toggleNode && props.toggleNode()
           }}>
          {props.isOpen ? "-" : "+" }
        </a>
      </span>
    );
  }

  let classes = [];
  if (props.active) {
    classes.push("active");
  }

  return (
    //<ListGroupItem className="d-flex justify-content-between align-items-center">
    <ListGroupItem active={props.active}>
      {toggle}
      <a href="#" onClick={props.onClickLabel}>
        {props.label}
      </a>
    </ListGroupItem>
  );
}
