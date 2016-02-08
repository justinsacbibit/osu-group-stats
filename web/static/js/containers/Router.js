import React from 'react';
import { Router, Route, browserHistory } from 'react-router';

import GroupStats from './GroupStats';
import Home from './Home';


export default class R extends React.Component {
  render() {
    return (
      <Router history={browserHistory}>
        <Route path="/g/:groupId/:tab" component={GroupStats} />
        <Route path="/g/:groupId" component={GroupStats} />
        <Route path="/" component={Home} />
      </Router>
    );
  }
}

