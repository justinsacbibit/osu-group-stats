import React, { PropTypes } from 'react';
import { routeActions } from 'react-router-redux';
import { connect } from 'react-redux';

import TabbedStats from '../components/TabbedStats';


class App extends React.Component {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    params: PropTypes.object.isRequired,
  };

  componentDidMount() {
    if (!this.props.params.groupId) {
      this.props.dispatch(routeActions.push('g/1/players'));
    } else if (!this.props.params.tab) {
      this.props.dispatch(routeActions.push(`g/${this.props.params.groupId}/players`));
    }
  }

  render() {
    return (
      <TabbedStats
        groupId={this.props.params.groupId}
        tab={this.props.params.tab} />
    );
  }
}

export default connect(() => ({}))(App);

