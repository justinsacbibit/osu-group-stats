import React, { PropTypes } from 'react';
import { Provider } from 'react-redux';
import Router from './Router';

export default class Root extends React.Component {
  static propTypes = {
    store: PropTypes.object.isRequired,
  };
  render() {
    const { store } = this.props;
    return (
      <Provider store={store}>
        <Router />
      </Provider>
    );
  }
}

