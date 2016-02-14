import React, { PropTypes } from 'react';
import classNames from 'classnames';
import { connect } from 'react-redux';

import {
  changePlayerTableSortOrder,
  fetchPlayers,
} from '../actions';
import { SORT_ORDERS } from '../constants';


class PlayerTable extends React.Component {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    groupId: PropTypes.string.isRequired,
    isLoading: PropTypes.bool.isRequired,
    players: PropTypes.array.isRequired,
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
  }

  handleOnClickSortableColumn(index) {
    const { dispatch } = this.props;

    dispatch(changePlayerTableSortOrder(index));
  }

  _sortPlayers(p1, p2) {
    const columnMap = [
      [p => p.pp_raw, -1],
      [p => p.pp_rank, 1],
      [p => p.pp_country_rank, 1],
      [p => p.playcount, -1],
      [p => p.accuracy, -1],
    ];
    const column = columnMap[this.props.sortOrder.index];
    let d1 = column[0](p1);
    let d2 = column[0](p2);
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

  render() {
    const sortableColumns = [
      'PP',
      'PP Rank',
      'Country Rank',
      'Playcount',
      'Accuracy',
    ];
    const players = this.props.players.slice();
    players.sort(this._sortPlayers.bind(this));
    return (
      <div>
        <h3>
          Click a column header to change the sort order
        </h3>
        <table className='ui sortable celled table'>
          <thead>
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
                      'sorted': sorted,
                      [this.props.sortOrder.direction]: sorted,
                    })}
                    key={index}
                    onClick={this.handleOnClickSortableColumn.bind(this, index)}>
                    {header}
                  </th>
                );
              })}
            </tr>
          </thead>
          <tbody>
            {players.map((player, index) => {
              return (
                <tr
                  key={index}>
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
    sortOrder: state.players.sortOrder,
  };
}

export default connect(select)(PlayerTable);

