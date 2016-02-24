import React, { PropTypes } from 'react';
import classNames from 'classnames';
import { connect } from 'react-redux';

import Dropdown from './Dropdown';
import DropdownItem from './DropdownItem';
import Slider from './Slider';

import {
  changePlayerTableRecentChangesStat,
  changePlayerTableShowRecentChanges,
  changePlayerTableSortOrder,
  fetchPlayers,
} from '../actions';
import { SORT_ORDERS } from '../constants';

const sortableColumns = [
  'PP',
  'PP Rank',
  'Country Rank',
  'Playcount',
  'Accuracy',
];
const columnMap = [
  [p => p.pp_raw, -1],
  [p => p.pp_rank, 1],
  [p => p.pp_country_rank, 1],
  [p => p.playcount, -1],
  [p => p.accuracy, -1],
];

class PlayerTable extends React.Component {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    groupId: PropTypes.string.isRequired,
    isLoading: PropTypes.shape({
      0: PropTypes.bool.isRequired,
      1: PropTypes.bool.isRequired,
      30: PropTypes.bool.isRequired,
      7: PropTypes.bool.isRequired,
    }).isRequired,
    players: PropTypes.shape({
      0: PropTypes.object.isRequired,
      1: PropTypes.object.isRequired,
      30: PropTypes.object.isRequired,
      7: PropTypes.object.isRequired,
    }).isRequired,
    recentChanges: PropTypes.shape({
      show: PropTypes.bool.isRequired,
      stat: PropTypes.string,
    }).isRequired,
    sortOrder: PropTypes.shape({
      direction: PropTypes.string.isRequired,
      index: PropTypes.number.isRequired,
    }).isRequired,
  };

  componentDidMount() {
    const {
      dispatch,
      groupId,
    } = this.props;

    dispatch(fetchPlayers(groupId));
    dispatch(fetchPlayers(groupId, 1));
    dispatch(fetchPlayers(groupId, 7));
    dispatch(fetchPlayers(groupId, 30));
  }

  _sortPlayers(deltas, p1, p2) {
    let column;
    if (deltas) {
      column = columnMap[sortableColumns.indexOf(this.props.recentChanges.stat)];
    } else {
      column = columnMap[this.props.sortOrder.index];
    }
    let d1 = column[0](p1);
    let d2 = column[0](p2);
    if (deltas && this.props.sortOrder.index > 0) {
      const map = [null, 1, 7, 30];
      d1 = d1 - column[0](this.props.players[map[this.props.sortOrder.index]][p1.user_id]);
      d2 = d2 - column[0](this.props.players[map[this.props.sortOrder.index]][p2.user_id]);
    }
    if (this.props.sortOrder.direction === SORT_ORDERS.ASCENDING) {
      const temp = d1;
      d1 = d2;
      d2 = temp;
    }
    if (column[1] === 1) {
      const temp = d1;
      d1 = d2;
      d2 = temp;
    }
    return d2 - d1;
  }

  handleOnClickSortableColumn(index) {
    const { dispatch } = this.props;

    dispatch(changePlayerTableSortOrder(index));
  }

  handleOnChangeSelectedStat(stat) {
    const { dispatch } = this.props;

    dispatch(changePlayerTableRecentChangesStat(stat));
  }

  handleChangeShowRecentChanges(show) {
    const { dispatch } = this.props;

    dispatch(changePlayerTableShowRecentChanges(show));
  }

  render() {
    //const players = this.props.players[0].slice();
    const players = Object.keys(this.props.players[0]).map(key => this.props.players[0][key]);
    players.sort(this._sortPlayers.bind(this, this.props.recentChanges.show));
    return (
      <div>
        <div className='ui form'>
          <div className='inline fields'>
            <div className='field'>
              <Slider
                id='showRecentChanges'
                onChange={this.handleChangeShowRecentChanges.bind(this)}
                value={this.props.recentChanges.show}>

                <label>Show recent changes</label>
              </Slider>
            </div>
            <div className={classNames('field', { disabled: !this.props.recentChanges.show })}>
              <div className='ui slider checkbox'>
                <Dropdown
                  defaultText='Stat'
                  id='playerStat'
                  onChange={this.handleOnChangeSelectedStat.bind(this)}
                  value={this.props.recentChanges.stat}>
                  {sortableColumns.map((stat, index) => {
                    return (
                      <DropdownItem
                        key={index}
                        value={stat}>
                        {stat}
                      </DropdownItem>
                    );
                  })}
                </Dropdown>
              </div>
            </div>
          </div>
        </div>
        <h3>
          Click a column header to change the sort order
        </h3>
        <table className='ui sortable celled table'>
          <thead>
              {this.props.recentChanges.show ?
                (() => {
                  const { sortOrder } = this.props;
                  return (
                    <tr>
                      <th>
                        Rank
                      </th>
                      <th>
                        Username
                      </th>
                      <th className={classNames({
                        sorted: sortOrder.index === 0,
                        [sortOrder.direction]: sortOrder.index === 0,
                      })}
                        onClick={this.handleOnClickSortableColumn.bind(this, 0)}>
                        {this.props.recentChanges.stat}
                      </th>
                      <th className={classNames({
                        sorted: sortOrder.index === 1,
                        [sortOrder.direction]: sortOrder.index === 1,
                      })}
                        onClick={this.handleOnClickSortableColumn.bind(this, 1)}>
                        1-Day Change
                      </th>
                      <th className={classNames({
                        sorted: sortOrder.index === 2,
                        [sortOrder.direction]: sortOrder.index === 2,
                      })}
                        onClick={this.handleOnClickSortableColumn.bind(this, 2)}>
                        7-Day Change
                      </th>
                      <th className={classNames({
                        sorted: sortOrder.index === 3,
                        [sortOrder.direction]: sortOrder.index === 3,
                      })}
                        onClick={this.handleOnClickSortableColumn.bind(this, 3)}>
                        30-Day Change
                      </th>
                    </tr>
                  );
                })()
                :
                <tr>
                  <th>
                    Rank
                  </th>
                  <th>
                    Username
                  </th>
                  {sortableColumns.map((header, index) => {
                    const sorted = index === this.props.sortOrder.index;
                    return (
                      <th
                        className={classNames(sorted, {
                          sorted: sorted,
                          [this.props.sortOrder.direction]: sorted,
                        })}
                        key={index}
                        onClick={this.handleOnClickSortableColumn.bind(this, index)}>
                        {header}
                      </th>
                    );
                  })}
                </tr>
              }
          </thead>
          <tbody>
            {players.map((player, index) => {
              if (this.props.recentChanges.show) {
                const i = sortableColumns.findIndex(col => col === this.props.recentChanges.stat);
                const columnFunc = columnMap[i][0];

                const current = columnFunc(player);
                const oneDayChange = current - columnFunc(this.props.players[1][player.user_id]);
                const sevenDayChange = current - columnFunc(this.props.players[7][player.user_id]);
                const thirtyDayChange = current - columnFunc(this.props.players[30][player.user_id]);
                return (
                  <tr key={index}>
                    <td>
                      {index + 1}
                    </td>
                    <td>
                      {player.username}
                    </td>
                    <td>
                      {current}
                    </td>
                    <td>
                      {oneDayChange.toFixed(2)}
                    </td>
                    <td>
                      {sevenDayChange.toFixed(2)}
                    </td>
                    <td>
                      {thirtyDayChange.toFixed(2)}
                    </td>
                  </tr>
                );
              }

              return (
                <tr key={index}>
                  <td>
                    {index + 1}
                  </td>
                  <td>
                    {player.username}
                  </td>
                  <td>
                    {player.pp_raw}
                  </td>
                  <td>
                    {player.pp_rank}
                  </td>
                  <td>
                    {player.pp_country_rank}
                  </td>
                  <td>
                    {player.playcount}
                  </td>
                  <td>
                    {player.accuracy.toFixed(2)}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    );
  }
}

function select(state) {
  return {
    isLoading: state.players.isLoading,
    players: state.players.players,
    recentChanges: state.players.recentChanges,
    sortOrder: state.players.sortOrder,
  };
}

export default connect(select)(PlayerTable);

