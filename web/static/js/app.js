import React, { Component } from 'react'
import RaisedButton from 'material-ui/lib/raised-button';
import Table from 'material-ui/lib/table/table';
import TableBody from 'material-ui/lib/table/table-body';
import TableFooter from 'material-ui/lib/table/table-footer';
import TableHeader from 'material-ui/lib/table/table-header';
import TableHeaderColumn from 'material-ui/lib/table/table-header-column';
import TableRow from 'material-ui/lib/table/table-row';
import TableRowColumn from 'material-ui/lib/table/table-row-column';
import Paper from 'material-ui/lib/paper';
import LeftNav from 'material-ui/lib/left-nav';
import MenuItem from 'material-ui/lib/menus/menu-item';
import classNames from 'classnames';


class Beatmaps extends Component {
  shouldComponentUpdate(nextProps) {
    return nextProps.selectedBeatmapIndex !== this.props.selectedBeatmapIndex
    || nextProps.beatmaps !== this.props.beatmaps;
  }

  handleOnRowSelection(selectedRow) {
    this.props.onRowSelection(selectedRow);
  }

  render() {
    return (
      <div>
        <h3>
          Click a beatmap to see the top scores for it
        </h3>
      <div className='ui grid'>
        <div className='nine wide column'>
          <table className='ui selectable celled table'>
            <thead>
              <tr>
                <th>
                  Rank
                </th>
                <th>
                  # Scores
                </th>
                <th>
                  Beatmap
                </th>
              </tr>
            </thead>
            <tbody>
              {this.props.beatmaps.map((beatmap, index) => {
                return (
                  <tr
                    className={classNames({ 'active': index === this.props.selectedBeatmapIndex })}
                    key={index}
                    onClick={this.handleOnRowSelection.bind(this, index)}
                    style={{ cursor: 'pointer' }}>
                    <td>
                      {index + 1}
                    </td>
                    <td>
                      {beatmap.scores.length}
                    </td>
                    <td>
                      {`${beatmap.artist} - ${beatmap.title} [${beatmap.version}] \\\\ ${beatmap.creator}`}
                    </td>
                  </tr>
                  );
              })}
            </tbody>
          </table>

        </div>
        <div className='seven wide column'>
          {this.props.selectedBeatmapIndex !== null ?
            (() => {
              const selectedBeatmap = this.props.beatmaps[this.props.selectedBeatmapIndex];

              return (
                <table className='ui celled table'>
                  <thead>
                    <tr>
                      <th>
                        Rank
                      </th>
                      <th>
                        Username
                      </th>
                      <th>
                        PP
                      </th>
                      <th>
                        Date
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    {selectedBeatmap.scores.map((score, index) => {
                      const scoreDate = new Date(score.date);
                      return (
                        <tr
                          key={index}>
                          <td>
                            {index + 1}
                          </td>
                          <td>
                            {score.user.username}
                          </td>
                          <td>
                            {score.pp}
                          </td>
                          <td>
                            {scoreDate.toLocaleString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' })}
                          </td>
                        </tr>
                        );
                    })}
                  </tbody>
                </table>
                );
            })()
              : null}
            </div>
          </div>
      </div>
    );
  }
}


class Players extends Component {
  constructor(props) {
    super(props);

    this.state = {
      sortIndex: 0,
      sortDirection: 'descending',
    };
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


export default class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      beatmaps: [],
      players: [],
      selectedBeatmapIndex: null,
      selectedTabIndex: 0,
    };
  }

  componentDidMount() {
    const root = location.protocol + '//' + location.host;
    $.get(`${root}/api/farmed-beatmaps`, beatmaps => {
      this.setState({
        beatmaps,
      });
    });
    $.get(`${root}/api/players`, players => {
      this.setState({
        players,
      });
    });
  }

  handleOnRowSelection(selectedBeatmapIndex) {
    this.setState({
      selectedBeatmapIndex,
    });
  }

  handleOnTouchTapBeatmaps() {
    this.setState({
      selectedTabIndex: 0,
    });
  }

  handleOnTouchTapPlayers() {
    this.setState({
      selectedTabIndex: 1,
    });
  }

  render() {
    const { selectedTabIndex } = this.state;
    return (
      <div>
        <div className='ui fixed inverted menu'>
          <div className='ui container'>
            <a className='header item'>
              UW/Laurier osu! Stats
            </a>
          </div>
        </div>
        <div
          className='ui main container'
          style={{ marginTop: '7em' }}>
          <div className='ui tabular menu'>
            <a
              className={classNames('item', { active: selectedTabIndex === 0 })}
              onClick={this.handleOnTouchTapBeatmaps.bind(this)}>Beatmaps</a>
            <a
              className={classNames('item', { active: selectedTabIndex === 1 })}
              onClick={this.handleOnTouchTapPlayers.bind(this)}>Players</a>
          </div>
          {selectedTabIndex === 0 ?
            <Beatmaps
              beatmaps={this.state.beatmaps}
              onRowSelection={this.handleOnRowSelection.bind(this)}
              selectedBeatmapIndex={this.state.selectedBeatmapIndex} />
          : null}
          {selectedTabIndex === 1 ?
            <Players
              players={this.state.players} />
          : null}
        </div>
      </div>
    )
  }
}
