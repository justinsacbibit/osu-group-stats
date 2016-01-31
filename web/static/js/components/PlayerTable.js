import React, { PropTypes } from 'react';
import classNames from 'classnames';
import { connect } from 'react-redux';

import {
  fetchPlayers,
} from '../actions';


class PlayerTable extends React.Component {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    groupId: PropTypes.string.isRequired,
    isLoading: PropTypes.bool.isRequired,
    players: PropTypes.array.isRequired,
  };

  constructor(props) {
    super(props);

    this.state = {
      sortIndex: 0,
      sortDirection: 'descending',
    };
  }

  componentDidMount() {
    const {
      dispatch,
      groupId,
      players,
    } = this.props;

    if (players.length === 0) {
      dispatch(fetchPlayers(groupId));
    }
  }

  handleOnClickSortableColumn(index) {
    if (index === this.state.sortIndex) {
      if (this.state.sortDirection === 'ascending') {
        this.setState({
          sortDirection: 'descending',
        });
      } else {
        this.setState({
          sortDirection: 'ascending',
        });
      }
    } else {
      this.setState({
        sortDirection: 'descending',
        sortIndex: index,
      });
    }
  }

  _sortPlayers(p1, p2) {
    const columnMap = [
      [p => p.pp_raw, -1],
      [p => p.pp_rank, 1],
      [p => p.pp_country_rank, 1],
      [p => p.playcount, -1],
      [p => p.accuracy, -1],
    ];
    const column = columnMap[this.state.sortIndex];
    let d1 = column[0](p1);
    let d2 = column[0](p2);
    if (this.state.sortDirection === 'ascending') {
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
                const sorted = index === this.state.sortIndex;
                return (
                  <th
                    className={classNames(sorted, {
                      'sorted': sorted,
                      [this.state.sortDirection]: sorted,
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
  };
}

export default connect(select)(PlayerTable);

