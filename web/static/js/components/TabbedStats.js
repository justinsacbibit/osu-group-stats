import React, { PropTypes } from 'react';
import classNames from 'classnames';
import { routeActions } from 'react-router-redux';
import { connect } from 'react-redux';

import {
  fetchGroup,
} from '../actions';

import FarmedBeatmaps from '../components/FarmedBeatmaps';
import GroupHeader from '../components/GroupHeader';
import LatestScores from '../components/LatestScores';
import PlayerTable from '../components/PlayerTable';
import StatsChart from '../components/StatsChart';


class TabbedStats extends React.Component {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    groupId: PropTypes.string.isRequired,
    group: PropTypes.object,
    tab: PropTypes.string,
  };

  componentDidMount() {
    const { dispatch, groupId } = this.props;
    dispatch(fetchGroup(groupId));
  }

  handleMenuItemSelection(index) {
    const routes = [
      'players',
      'scores',
      'graph',
      'beatmaps',
    ];
    const route = `/g/${this.props.groupId}/${routes[index]}`;
    this.props.dispatch(routeActions.push(route));
  }

  render() {
    const { groupId, group, tab } = this.props;
    const selectedTabIndex = {
      players: 0,
      scores: 1,
      graph: 2,
      beatmaps: 3,
    }[tab];

    const menuItems = [
      'Players',
      'Scores',
      'Player Charts',
      'Beatmaps',
    ];

    return (
      <div>
        {group ?
          <GroupHeader group={group} />
          : null}
        <div className='ui tabular menu'>
          {menuItems.map((item, index) => {
            return (
              <a
                className={classNames('item', { active: selectedTabIndex === index })}
                key={index}
                onClick={this.handleMenuItemSelection.bind(this, index)}>
                {item}
              </a>
              );
          })}
        </div>
        {selectedTabIndex === 0 ?
          <PlayerTable
            groupId={groupId} />
        : null}
        {selectedTabIndex === 1 ?
          <LatestScores
            groupId={groupId} />
        : null}
        <StatsChart
          groupId={groupId}
          visible={selectedTabIndex === 2} />
        {selectedTabIndex === 3 ?
          <FarmedBeatmaps
            groupId={groupId} />
        : null}
      </div>
    );
  }
}

function select(state) {
  return {
    group: state.group.group,
  };
}

export default connect(select)(TabbedStats);

