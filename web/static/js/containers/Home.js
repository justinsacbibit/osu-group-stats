import React, { PropTypes } from 'react';
import { connect } from 'react-redux';

import App from './App';
import Groups from '../components/Groups';


class Home extends React.Component {
  static propTypes = {
    params: PropTypes.object.isRequired,
  };

  render() {
    return (
      <App params={this.props.params}>
        <Groups />
      </App>
    );
  }
}

export default connect(() => ({}))(Home);

