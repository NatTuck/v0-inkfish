import React, { useState } from 'react';
import ReactDOM from 'react-dom';
import { FormGroup, Label, Input, TabContent, TabPane,
         Nav, NavItem, NavLink } from 'reactstrap';
import classnames from 'classnames';
import _ from 'lodash';

import { bucket_table } from './sheet';

export default function init_gradesheet(root_id) {
  let root = document.getElementById(root_id);
  if (root) {
    ReactDOM.render(<GradeSheet sheet={window.gradesheet} />, root);
  }
}

function GradeSheet({sheet}) {
  const [activeTab, setActiveTab] = useState('0');

  function setTab(name) {
    return (_ev) => {
      if (activeTab != name) {
        setActiveTab(name);
      }
    };
  }

  function TabLink({name, children}) {
    return (
        <NavItem>
          <NavLink className={ classnames({ active: activeTab == name }) }
                   onClick={setTab(name)} >
            { children }
          </NavLink>
        </NavItem>
    );
  }

  let bucketLinks = [];
  let bucketTabs = [];

  for (let bucket of _.sortBy(sheet.buckets, (bb) => bb.name)) {
    bucketLinks.push(
      <TabLink key={bucket.id} name={bucket.id}>
        { bucket.name }
      </TabLink>
    );

    let table = bucket_table(sheet, bucket.id);
    bucketTabs.push(
      <TabPane key={bucket.id} tabId={bucket.id}>
        <Grid table={table} />
      </TabPane>
    )
  }

  return (
    <div>
      <Nav tabs>
        <TabLink name="0">
          Totals
        </TabLink>
        { bucketLinks }
      </Nav>
      <TabContent activeTab={activeTab}>
        <TabPane tabId="0">
          <p>Totals</p>
        </TabPane>
        { bucketTabs }
      </TabContent>
    </div>
  );
}

function Grid({table}) {
  const [filterText, setFilterText] = useState("");

  let headers = table.cols.map((col) => (<th key={col.id}>{col.name}</th>));
  let rows = table.rows
      .filter((row) => row.name.toLowerCase().includes(filterText.toLowerCase()))
      .map((row) => {
    let cols = row.grades.map((item, ii) => {
      return (<td key={ii}>{item.grade.toFixed(1)}</td>)
    });
    return (
      <tr key={row.id}>
        <td>{row.name}</td>
        { cols }
      </tr>
    );
  });

  return (
    <div>
      <div className="form-inline">
        <FormGroup>
          <Label for="table-filter">Filter by Name:</Label>
          <Input id="table-filter" type="text" value={filterText}
                 onChange={(ev) => setFilterText(ev.target.value)} />
        </FormGroup>
      </div>
      <table className="table table-striped">
        <thead>
          <tr>
            <th>Name</th>
            { headers }
          </tr>
        </thead>
        <tbody>
          { rows }
        </tbody>
      </table>
    </div>
  );
}
