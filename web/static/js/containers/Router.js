import React from 'react';
import { Router, Route, browserHistory } from 'react-router';
import App from './App';


export default class R extends React.Component {
  render() {
    return (
      <Router history={browserHistory}>
        <Route path="/g/:groupId/:tab" component={App} />
        <Route path="/g/:groupId" component={App} />
        <Route path="/" component={App} />
      </Router>
    );
  }
}

