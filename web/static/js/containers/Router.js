import React from 'react';
import { Router, Route, browserHistory } from 'react-router';

import GroupCreation from './GroupCreation';
import GroupStats from './GroupStats';
import Home from './Home';
import FAQ from './FAQ';


export default class R extends React.Component {
  render() {
    return (
      <Router history={browserHistory}>
        <Route path="/g/new" component={GroupCreation} />
        <Route path="/g/:groupId/:tab" component={GroupStats} />
        <Route path="/g/:groupId" component={GroupStats} />
        <Route path="/faq" component={FAQ} />
        <Route path="/" component={Home} />
      </Router>
    );
  }
}

