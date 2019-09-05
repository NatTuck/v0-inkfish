
import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

let inputs = new Map();

class NumberInput extends React.Component {
  constructor(props) {
    super(props);
    if (!inputs.has(props.grade_column_id)) {
      inputs.set(props.grade_column_id, []);
    }
    inputs.get(props.grade_column_id).push(this);

    this.state = {
      sub_id: props.sub_id,
      grade_column_id: props.grade_column_id,
      saved_score: -1,
      score: props.score,
      points: props.points,
      edit: false,
      saving: false,
      error: null,
    };
  }

  change(ev) {
    ev.preventDefault();
    this.setState({score: ev.target.value});
  }

  keypress(ev) {
    if (ev.key == "Enter") {
      this.save();
    }
  }

  save() {
    let body = JSON.stringify({
      grade: {
        sub_id: this.state.sub_id,
        grade_column_id: this.state.grade_column_id,
        score: this.state.score,
      }
    });

    $.ajax(save_grade_path(this.state.sub_id), {
      method: "post",
      dataType: "json",
      contentType: "application/json; charset=UTF-8",
      data: body,
      headers: { "x-csrf-token": window.csrf_token },
      success: this.save_success.bind(this),
      error: this.save_error.bind(this),
    });

    this.setState({saving: true});
  }

  save_success(resp) {
    this.setState({saving: false, saved_score: resp.score, error: null});
  }
  
  save_error(resp) {
    let msg = `${resp.status} ${resp.statusText}`;
    console.log("Error saving grade: ", msg);
    console.log(resp);
    this.setState({saving: false, error: msg});
  }

  setEdit(edit) {
    this.setState({edit: edit, error: null});
  }

  render() {
    if (!this.state.edit) {
      return <div>{this.state.score} / {this.state.points}</div>;
    }

    if (this.state.error) {
      return (
        <div>
          {this.state.score} / {this.state.points}
          <div className="badge badge-danger ml-1">{this.state.error}</div>
        </div>
      );
    }

    
    let btn = <img src="/images/loading.gif" />;

    if (!this.state.saving) {
      let enabled = this.state.score != this.state.saved_score;
      btn = (
        <button className="btn btn-secondary btn-sm"
                onClick={this.save.bind(this)}
                disabled={!enabled}>
          Save
        </button>
      );
    }

    return (
      <div>
        <input type="number" className="number-grade-input"
               value={this.state.score}
               onKeyPress={this.keypress.bind(this)}
               onChange={this.change.bind(this)} />
        {btn}
      </div>
    );
  }
}

class NumberInputToggle extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      grade_column_id: props.grade_column_id,
      edit: false,
    };
  }

  toggle(ev) {
    ev.preventDefault();
    let edit = !this.state.edit;
    _.each(inputs.get(this.state.grade_column_id), (item) => {
      item.setEdit(edit);
    });
    this.setState({edit: edit});
  }

  render() {
    let text = this.state.edit ? "Hide" : "Show";
    return (
      <span>
        (<a href="#" onClick={this.toggle.bind(this)}>{text}</a>)
      </span>
    );
  }
}

function setup() {
  $('div.number-grade-cell').each((_ii, elem) => {
    var ee = $(elem);
    ReactDOM.render(
      <NumberInput score={ee.data('score')}
                   points={ee.data('points')}
                   sub_id={ee.data('sub-id')}
                   grade_column_id={ee.data('grade-column-id')} />,
      elem
    );
  });

  $('span.toggle-number-inputs').each((_ii, elem) => {
    var ee = $(elem);
    ReactDOM.render(
      <NumberInputToggle grade_column_id={ee.data('grade-column-id')} />,
      elem
    );
  });
}

$(setup);
