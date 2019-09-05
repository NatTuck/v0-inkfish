
import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';
import $ from 'jquery';
import deepFreeze from 'deep-freeze';

export default function init() {
  let root = document.getElementById('team-manager');
  if (root) {
    let data = window.teamset_data;
    data.new_team_regs = [];
    ReactDOM.render(<TeamManager data={data} />, root);
  }
}

class TeamManager extends React.Component {
  constructor(props) {
    super(props);
    this.state = deepFreeze(props.data);
  }

  remove_member(reg) {
    console.log("remove", reg);
    let regs = _.filter(
      this.state.new_team_regs,
      (rr) => (rr.id != reg.id)
    );
    this.setState(deepFreeze({
      ...this.state,
      new_team_regs: regs,
    }));
  }

  add_member(reg) {
    console.log("add", reg);
    let regs = _.concat(this.state.new_team_regs, reg);
    this.setState(deepFreeze({
      ...this.state,
      new_team_regs: regs,
    }));
  }

  reset_data(data) {
    data.new_team_regs = [];
    this.setState(deepFreeze(data));
  }

  create_team(_ev) {
    console.log("create", this.state.new_team_regs);
    let body = {
      team: {
        active: true,
        teamset_id: this.state.id,
        reg_ids: _.map(this.state.new_team_regs, (reg) => reg.id),
      }
    };

    $.ajax(window.create_team_path, {
      method: "post",
      dataType: "json",
      contentType: "application/json; charset=UTF-8",
      data: JSON.stringify(body),
      headers: { "x-csrf-token": window.csrf_token },
      success: (data, status) => {
        data = data.data;
        console.log("created", data);
        this.reset_data(data.teamset);
      },
      error: (xhr, status) => {
        console.log("create failed", status, xhr);
      }
    });
  }

  set_active_team(team, active) {
    console.log("set active", team, active);
    let body = { team: { active: active } };
    let path = window.team_path_template.replace("ID", team.id);
    $.ajax(path, {
      method: "patch",
      dataType: "json",
      contentType: "application/json; charset=UTF-8",
      data: JSON.stringify(body),
      headers: { "x-csrf-token": window.csrf_token },
      success: (data, status) => {
        data = data.data;
        console.log("created", data);
        this.reset_data(data.teamset);
      },
      error: (xhr, status) => {
        console.log("create failed", status, xhr);
      }
    });
  }

  delete_team(team) {
    console.log("delete", team);

    let path = window.team_path_template.replace("ID", team.id);
    $.ajax(path, {
      method: "delete",
      dataType: "json",
      contentType: "application/json; charset=UTF-8",
      data: JSON.stringify({}),
      headers: { "x-csrf-token": window.csrf_token },
      success: (data, status) => {
        data = data.data;
        console.log("deleted", data.id);
        this.reset_data(data.teamset);
      },
      error: (xhr, status) => {
        console.log("delete failed", status, xhr);
      }
    });
  }

  student_teams_map() {
    let student_teams = new Map();
    for (let reg of this.state.course.regs) {
      if (reg.is_student) {
        student_teams.set(reg.id, []);
      }
    }

    for (let team of this.state.teams) {
      if (team.active) {
        for (let reg of team.regs) {
          let xs = student_teams.get(reg.id) || [];
          xs.push(team);
          student_teams.set(reg.id, xs);
        }
      }
    }

    return student_teams;
  }

  extra_students() {
    let student_teams = this.student_teams_map();
    let new_regs = this.state.new_team_regs;
    let new_ids = new Set(_.map(new_regs, (reg) => reg.id));
    return _.filter(this.state.course.regs, (reg) => {
      let ts = student_teams.get(reg.id);
      return reg.is_student && ts.length == 0 && !new_ids.has(reg.id);
    });
  }

  render() {
    let active_teams   = _.filter(this.state.teams, (team) => team.active);
    let inactive_teams = _.filter(this.state.teams, (team) => !team.active);

    let extra = this.extra_students();

    return (
      <div className="row">
        <div className="col">
          <h2>Active Teams</h2>
          <TeamTable root={this} teams={active_teams} />

          <h2>Inactive Teams</h2>
          <TeamTable root={this} teams={inactive_teams} />
        </div>
        <div className="col">
          <h2>New Team</h2>
          <RegTable root={this}
                    regs={this.state.new_team_regs}
                    controls={RemoveFromTeam} />
          <button className="btn btn-primary"
                  onClick={this.create_team.bind(this)}>
            Create Team
          </button>
         
          <h2>Extra Students</h2>
          <RegTable root={this} regs={extra} controls={AddToTeam}/>
        </div>
      </div>
    );
  }
}

function RegTable({root, regs, controls}) {
  let Controls = controls;
  let rows = _.map(regs, (reg) => (
    <tr key={reg.id}>
      <td>{reg.user.name}</td>
      <td><Controls root={root} reg={reg} /></td>
    </tr>
  ));

  return (
    <table className="table table-striped">
      <tbody>
        {rows}
      </tbody>
    </table>
  );
}

function AddToTeam({root, reg}) {
  let on_click = (_ev) => {
    root.add_member(reg);
  };

  return (
    <button className="btn btn-secondary btn-sm"
            onClick={on_click}>
      Add
    </button>
  );
}

function RemoveFromTeam({root, reg}) {
  let on_click = (_ev) => {
    root.remove_member(reg);
  };

  return (
    <button className="btn btn-danger btn-sm"
            onClick={on_click}>
      Remove
    </button>
  );
}

function TeamTable({root, teams, controls}) {
  let rows = _.map(teams, (team) => (
    <TeamRow key={team.id} root={root} team={team} controls={controls} />
  ));

  return (
    <table className="table table-striped">
      <thead>
        <tr>
          <th>#</th>
          <th>Members</th>
          <th>Subs</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        {rows}
      </tbody>
    </table>
  );
}

function TeamRow({root, team, controls}) {
  let Controls = controls;
  let members = _.map(team.regs, (reg) => reg.user.name);
  return (
    <tr>
      <td>#{team.id}</td>
      <td>{members.join(', ')}</td>
      <td>{team.subs.length}</td>
      <td><TeamControls root={root} team={team} /></td>
    </tr>
  );
}

function TeamControls({root, team}) {
  let btns = [];

  if (team.active) {
    btns.push(
      <button key="deact"
              className="btn btn-secondary btn-sm"
              onClick={() => root.set_active_team(team, false)}>
        Deactivate
      </button>
    );
  }
  else {
    btns.push(
      <button key="act"
              className="btn btn-secondary btn-sm"
              onClick={() => root.set_active_team(team, true)}>
        Activate
      </button>
    );
  }

  if (team.subs.length == 0) {
    btns.push(
      <button key="delete"
              className="btn btn-danger btn-sm"
              onClick={() => root.delete_team(team)}>
        Delete
      </button>
    );
  }

  return <div>{btns}</div>;
}
