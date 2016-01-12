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

  handleOnRowSelection(selectedRows) {
    if (selectedRows.length === 1) {
      const [ selectedRow ] = selectedRows;
      this.props.onRowSelection(selectedRow);
    }
  }

  render() {
    return (
      <div>
        <Paper style={{ display: 'inline-block', marginLeft: '130px', width: '800px' }}>
          <Table
            height='500px'
            onRowSelection={this.handleOnRowSelection.bind(this)}
            selectable>
            <TableHeader
              displaySelectAll={false}>
              <TableRow>
                <TableHeaderColumn style={{ width: '20px' }}>
                  Rank
                </TableHeaderColumn>
                <TableHeaderColumn style={{ width: '20px' }}>
                  # Scores
                </TableHeaderColumn>
                <TableHeaderColumn>
                  Artist
                </TableHeaderColumn>
                <TableHeaderColumn>
                  Title
                </TableHeaderColumn>
                <TableHeaderColumn>
                  Version
                </TableHeaderColumn>
              </TableRow>
            </TableHeader>
            <TableBody>
              {this.props.beatmaps.map((beatmap, index) => {
                return (
                  <TableRow
                    key={index}
                    selected={index === this.props.selectedBeatmapIndex}>
                    <TableRowColumn style={{ width: '20px' }}>
                      {index + 1}
                    </TableRowColumn>
                    <TableRowColumn style={{ width: '20px' }}>
                      {beatmap.scores.length}
                    </TableRowColumn>
                    <TableRowColumn>
                      {beatmap.artist}
                    </TableRowColumn>
                    <TableRowColumn>
                      {beatmap.title}
                    </TableRowColumn>
                    <TableRowColumn>
                      {beatmap.version}
                    </TableRowColumn>
                  </TableRow>
                  );
              })}
            </TableBody>
          </Table>
        </Paper>

        {this.props.selectedBeatmapIndex !== null ?
          (() => {
            const selectedBeatmap = this.props.beatmaps[this.props.selectedBeatmapIndex];

            return (
              <Paper style={{ marginLeft: '50px', width: '430px', display: 'inline-block' }}>
                <Table height='500px'>
                  <TableHeader
                    adjustForCheckbox={false}
                    displaySelectAll={false}>
                    <TableRow>
                      <TableHeaderColumn style={{ width: '10px' }}>
                        Rank
                      </TableHeaderColumn>
                      <TableHeaderColumn style={{ width: '100px' }}>
                        Username
                      </TableHeaderColumn>
                      <TableHeaderColumn style={{ width: '50px' }}>
                        PP
                      </TableHeaderColumn>
                      <TableHeaderColumn>
                        Date
                      </TableHeaderColumn>
                    </TableRow>
                  </TableHeader>
                  <TableBody
                    adjustForCheckbox={false}
                    displayRowCheckbox={false}>
                    {selectedBeatmap.scores.map((score, index) => {
                      const scoreDate = new Date(score.date);
                      return (
                        <TableRow
                          key={index}>
                          <TableRowColumn style={{ width: '10px' }}>
                            {index + 1}
                          </TableRowColumn>
                          <TableRowColumn style={{ width: '100px' }}>
                            {score.user.username}
                          </TableRowColumn>
                          <TableRowColumn style={{ width: '50px' }}>
                            {score.pp}
                          </TableRowColumn>
                          <TableRowColumn>
                            {scoreDate.toLocaleString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' })}
                          </TableRowColumn>
                        </TableRow>
                        );
                    })}
                  </TableBody>
                </Table>
              </Paper>
            );
          })()
        : null}
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

  }

  handleOnTouchTapPlayers() {

  }

  render() {
    return (
      <div>
        <Beatmaps
          beatmaps={this.state.beatmaps}
          onRowSelection={this.handleOnRowSelection.bind(this)}
          selectedBeatmapIndex={this.state.selectedBeatmapIndex} />

        <Players
          players={this.state.players} />
      </div>
    )
  }
}
