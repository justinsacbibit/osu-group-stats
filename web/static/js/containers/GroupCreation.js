import React, { PropTypes } from 'react';
import { connect } from 'react-redux';

import App from '../containers/App';
import GroupCreationComponent from '../components/GroupCreation';


class GroupCreation extends React.Component {
  static propTypes = {
    params: PropTypes.object.isRequired,
  };

  render() {
    return (
      <App params={this.props.params}>
        <GroupCreationComponent />
      </App>
    );
  }
}

export default connect(() => ({}))(GroupCreation);
