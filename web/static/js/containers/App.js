import React, { PropTypes } from 'react';
import { connect } from 'react-redux';

import TopBar from '../components/TopBar';


class App extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    params: PropTypes.object.isRequired,
  };

  render() {
    return (
      <div>
        <TopBar params={this.props.params} />
        <div
          className='ui main container'
          style={{ marginTop: '7em' }}>
          {this.props.children}
        </div>
      </div>
    );
  }
}

export default connect(() => ({}))(App);

