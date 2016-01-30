import React from 'react';
import { Router, Route, browserHistory } from 'react-router';
import App from './App';


export default class R extends React.Component {
  render() {
    return (
      <Router history={browserHistory}>
        <Route path="/" component={App} />
        <Route path="/g/:groupId" component={App} />
      </Router>
    );
  }
}

