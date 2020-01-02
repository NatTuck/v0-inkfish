
import React from 'react';
import ReactDOM from 'react-dom';
import TreeMenu, {defaultChildren} from 'react-simple-tree-menu';
import { ListGroup, ListGroupItem, Input } from 'reactstrap';
import _ from 'lodash';
import deepFreeze from 'deep-freeze';
import viewer from './code-viewer';

export default function init_view() {
  let root = document.getElementById('code-file-tree');
  if (root) {
    ReactDOM.render(<FileTree data={window.code_view_data} />, root);
  }
}

class FileTree extends React.Component {
  constructor(props) {
    super(props);
    viewer.set_grade_callback(this.update_grade.bind(this));

    let dirs = list_top_dirs(props.data.files);
    let grade = props.data.grade;

    console.log(grade);

    this.state = deepFreeze({
      sub_id: props.data.sub_id,
      grade_id: props.data.grade_id,
      files: props.data.files,
      active: "[root]",
      dirs: dirs,
      grade: grade,
    });
  }

  update_grade(grade) {
    console.log("update_grade", grade);

    this.setState(deepFreeze({
      ...this.state,
      grade: grade,
    }));
  }

  pick_file(ev, props) {
    ev.preventDefault();
    viewer.set_file(props);
    this.setState(deepFreeze({
      ...this.state,
      active: props.path,
    }));
  }

  render() {
    let comment_counts = new Map();
    for (let lc of this.state.grade.line_comments) {
      if (comment_counts.has(lc.path)) {
        let count = comment_counts.get(lc.path);
        comment_counts.set(lc.path, count + 1);
      }
      else {
        comment_counts.set(lc.path, 1);
      }
    }

    let grade_info = "";
    if (this.state.grade.grade_column) {
        grade_info = <GradeInfo grade={this.state.grade} />;
    }

    return (
      <div>
        {grade_info}
        <TreeMenu
          data={[this.state.files]}
          onClickItem={({...props}) => this.pick_file(props)}
          debounceTime={5}
          initialOpenNodes={this.state.dirs}>
          {({_search, items}) => (
            <ListGroup>
              {items.map((props) => {
                return (
                  <ListItem {...props}
                            comment_counts={comment_counts}
                            active={props.label == this.state.active}
                            onClickLabel={(ev) => this.pick_file(ev, props)}/>
                );
              })}
            </ListGroup>
          )}
        </TreeMenu>
      </div>
    );
  }
}

function GradeInfo({grade}) {
  let count = grade.line_comments.length;
  let sum   = _.sumBy(grade.line_comments, (lc) => +lc.points);
  if (sum > 0) {
    sum = `+${sum}`;
  }

  let team_users = _.map(grade.sub.team.regs, (reg) => reg.user.name);

  return (
    <div className="card">
      <div className="card-body">
        <h4 className="card-title">Grade Info</h4>
        <p>Base: {grade.grade_column.base}</p>
        <p>Comments: {count} ({sum})</p>
        <p>Total: {grade.score} / {grade.grade_column.points}</p>

        <h4>Submitter</h4>
        <p>Team: {team_users.join(', ')}</p>
        <p>User: {grade.sub.reg.user.name}</p>
      </div>
    </div>
  );
}

function list_top_dirs(data) {
  if (data.type != "directory") {
    return [];
  }

  let ys = [data.key];

  for (let node of data.nodes) {
    ys = _.concat(ys, list_top_dirs(node));
  }

  return ys;
}

function ListItem(props) {
  if (props.hasNodes) {
    return <DirListItem {...props} />;
  }

  let badge = "";
  if (props.comment_counts.has(props.path)) {
    badge = (
      <span className="badge badge-info">
        {props.comment_counts.get(props.path)}
      </span>
    );
  }

  return (
    <ListGroupItem active={props.active}>
      <span className="tree-toggle">&nbsp;</span>
      <a href="#" onClick={props.onClickLabel}>
        {props.label}
      </a>
      <span className="mx-3">
        {badge}
      </span>
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
        <a href="#" onClick={toggle}>
          {props.isOpen ? "-" : "+" }
        </a>
      </span>
      <a href="#" onClick={toggle}>
        {props.label}
      </a>
    </ListGroupItem>
  );
}
