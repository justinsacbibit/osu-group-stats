import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { routeActions } from 'react-router-redux';

import { fetchGroups } from '../actions';
import { MODES } from '../constants/osu';


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

    if (isLoading) {
      return (
        <div className='ui active centered large inline loader' />
      );
    }

    return (
      <div>
        {groups.map((group, index) => {
          return (
            <div
              className=''
              key={index}>
              <a
                className='ui link'
                href='#'
                onClick={this.handleOnClickGroup.bind(this, group.id)}>
                {group.id} {MODES[group.mode]}
              </a>
            </div>
          );
        })}
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

