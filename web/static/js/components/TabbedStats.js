import React, { PropTypes } from 'react';
import classNames from 'classnames';
import { routeActions } from 'react-router-redux';
import { connect } from 'react-redux';

import FarmedBeatmaps from '../components/FarmedBeatmaps';
import LatestScores from '../components/LatestScores';
import PlayerTable from '../components/PlayerTable';
import StatsChart from '../components/StatsChart';


class TabbedStats extends React.Component {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    groupId: PropTypes.string.isRequired,
    tab: PropTypes.string,
  };
  static defaultProps = {
    groupId: '1',
  };

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
    const { groupId, tab } = this.props;
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
        <div className='ui fixed inverted menu'>
          <div className='ui container'>
            <a className='header item'>
              <img src='/images/uw.png' />
              &nbsp;
              UW/Laurier osu! Stats
            </a>
          </div>
        </div>
        <div
          className='ui main container'
          style={{ marginTop: '7em' }}>
          <div className='ui tabular menu'>
            {menuItems.map((item, index) => {
              return (
                <a
                  className={classNames('item', { active: selectedTabIndex === index })}
                  key={index}
                  onClick={this.handleMenuItemSelection.bind(this, index)}>{item}</a>
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
          {selectedTabIndex === 2 ?
            <StatsChart
              groupId={groupId} />
          : null}
          {selectedTabIndex === 3 ?
            <FarmedBeatmaps
              groupId={groupId} />
          : null}
        </div>
      </div>
    );
  }
}

export default connect(() => ({}))(TabbedStats);

