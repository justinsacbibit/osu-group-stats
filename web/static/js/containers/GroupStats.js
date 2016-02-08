import React, { PropTypes } from 'react';
import { connect } from 'react-redux';

import App from '../containers/App';
import TabbedStats from '../components/TabbedStats';


class GroupStats extends React.Component {
  static propTypes = {
    params: PropTypes.object.isRequired,
  };

  render() {
    return (
      <App params={this.props.params}>
        <TabbedStats
          groupId={this.props.params.groupId}
          tab={this.props.params.tab} />
      </App>
    );
  }
}

export default connect(() => ({}))(GroupStats);

