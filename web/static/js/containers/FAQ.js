import React, { PropTypes } from 'react';
import { connect } from 'react-redux';

import App from './App';
import FAQComponent from '../components/FAQ';


class FAQ extends React.Component {
  static propTypes = {
    params: PropTypes.object.isRequired,
  };

  render() {
    return (
      <App params={this.props.params}>
        <FAQComponent />
      </App>
    );
  }
}

export default connect(() => ({}))(FAQ);
