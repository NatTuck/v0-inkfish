
import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

let inputs = [];

class NumberInput extends React.Component {
  constructor(props) {
    super(props);
    inputs.push(this);
    this.state = {
      sub_id: props.sub_id,
      grader_id: props.grader_id,
      saved_value: -1,
      value: props.value,
      edit: false,
      saving: false,
    };
  }

  change(ev) {
    this.setState({value: ev.target.value});
  }

  save() {
    let body = JSON.stringify({
      grade: {
        sub_id: this.state.sub_id,
        grader_id: this.state.grader_id,
        score: this.state.value,
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
    console.log(resp)
    this.setState({saving: false, saved_value: resp.score});
  }
  
  save_error(resp) {
    console.log("Error saving grade: ", resp.status, resp.statusText);
    console.log(resp);
    this.setState({saving: false});
  }

  toggle() {
    this.setState({edit: !this.state.edit});
  }

  render() {
    if (this.state.edit) {
      let btn = <img src="/images/loading.gif" />;

      if (!this.state.saving) {
        let enabled = this.state.value != this.state.saved_value;
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
                 value={this.state.value}
                 onChange={this.change.bind(this)} />
          {btn}
        </div>
      );
    }
    else {
      return <div>{this.state.value}</div>;
    }
  }
}

function setup() {
  $('div.number-grade-cell').each((_ii, elem) => {
    var ee = $(elem);
    ReactDOM.render(
      <NumberInput value={ee.data('value')}
                   sub_id={ee.data('sub-id')}
                   grader_id={ee.data('grader-id')} />,
      elem
    );
  });

  $('a.toggle-number-inputs').click(() => {
    _.each(inputs, (item) => item.toggle());
  });
}

$(setup);
