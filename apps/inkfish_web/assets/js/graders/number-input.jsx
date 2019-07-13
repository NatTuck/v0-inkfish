
import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

let inputs = new Map();

class NumberInput extends React.Component {
  constructor(props) {
    super(props);
    if (!inputs.has(props.grader_id)) {
      inputs.set(props.grader_id, []);
    }
    inputs.get(props.grader_id).push(this);

    this.state = {
      sub_id: props.sub_id,
      grader_id: props.grader_id,
      saved_score: -1,
      score: props.score,
      points: props.points,
      edit: false,
      saving: false,
      error: null,
    };
  }

  change(ev) {
    this.setState({score: ev.target.value});
  }

  save() {
    let body = JSON.stringify({
      grade: {
        sub_id: this.state.sub_id,
        grader_id: this.state.grader_id,
        score: this.state.score,
      }
    });

    $.ajax(window.save_grade_path, {
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
      grader_id: props.grader_id,
      edit: false,
    };
  }

  toggle(ev) {
    ev.preventDefault();
    let edit = !this.state.edit;
    _.each(inputs.get(this.state.grader_id), (item) => {
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
                   grader_id={ee.data('grader-id')} />,
      elem
    );
  });

  $('span.toggle-number-inputs').each((_ii, elem) => {
    var ee = $(elem);
    ReactDOM.render(
      <NumberInputToggle grader_id={ee.data('grader-id')} />,
      elem
    );
  });
}

$(setup);