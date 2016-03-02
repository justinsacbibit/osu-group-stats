import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { routeActions } from 'react-router-redux';

import { fetchGroups } from '../actions';
import GroupTable from '../components/GroupTable';
import Summary from '../components/Summary';


class Groups extends React.Component {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    groups: PropTypes.array.isRequired,
    isLoading: PropTypes.bool.isRequired,
  };

  componentDidMount() {
    this.props.dispatch(fetchGroups());
  }

  handleOnClickGroup(groupId) {
    this.props.dispatch(routeActions.push(`g/${groupId}/players`));
  }

  render() {
    const {
      groups,
      isLoading,
    } = this.props;

    return (
      <div>
        <Summary />
        <br />
        <GroupTable
          groups={groups}
          isLoading={isLoading}
          onClickGroup={this.handleOnClickGroup.bind(this)} />
      </div>
    );
  }
}

function select(state) {
  return {
    groups: state.groups.groups,
    isLoading: state.groups.isLoading,
  };
}

export default connect(select)(Groups);
