import React, { Component } from 'react';
import classNames from 'classnames';


function getModsArray(curMods) {
  const modMap = [
    ['NF', 1],
    ['EZ', 2],
    ['HD', 8],
    ['HR', 16],
    ['SD', 32],
    ['DT', 64],
    ['RX', 128],
    ['HT', 256],
    ['NC', 512], // Only set along with DoubleTime. i.e: NC only gives 576
    ['FL', 1024],
    ['AP', 2048],
    ['SO', 4096],
    ['PF', 16384],
    // Where is SD?
  ];

  const mods = [];
  for (let i = modMap.length - 1; i >= 0; i--) {
    const arr = modMap[i];
    const [mod, val] = arr;
    if (val > curMods) continue;
    curMods -= val;
    if (val == 512) curMods -= 64;
    mods.push(mod);
  }

  return mods;
}


class Beatmaps extends Component {
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
          <div className='eight wide column'>
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
          <div className='eight wide column'>
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
                         Mods
                       </th>
                       <th>
                         Date
                       </th>
                     </tr>
                   </thead>
                   <tbody>
                     {selectedBeatmap.scores.map((score, index) => {
                        const scoreDate = new Date(score.date);

                        const mods = getModsArray(score.enabled_mods);

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
                              {mods.join(', ')}
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
    if (!this.props.visible) return null;

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


class PlayerCharts extends Component {
  constructor(props) {
    super(props);
    this.state = {
      data: [],
      initted: false,
      player1: 'influxd',
      player2: 'Arneshie-',
      stat: 0,
    };
  }

  componentDidMount() {
    const root = location.protocol + '//' + location.host;
    $.get(`${root}/api/daily-snapshots`, (data) => {
      this.setState({
        data,
      });
    });
  }

  componentDidUpdate(prevProps) {
    if (!this.state.initted && !prevProps.visible && this.props.visible) {
      this._initHighChart();
      this.setState({
        initted: true,
      });
    }
  }

  _initHighChart(stat = 0) {
    let { data } = this.state;
    $(() => {
      const { player1, player2 } = this.state;
      const usernames = [player1, player2];
      data = data.filter(data => usernames.map(username => username.toLowerCase()).indexOf(data.username.toLowerCase()) >= 0);
      const text = stat === 0 ? 'Performance Points' : 'Play Count';
      $('#container').highcharts({
        chart: {
          type: 'line'
        },
        title: {
          text: `UW/Laurier osu! ${text}`
        },
        xAxis: {
          type: 'datetime'
        },
        yAxis: {
          title: {
            text,
          }
        },
        series: data.map((user, i) => {
          return {
            name: user.username,
            //marker: {
              //symbol: i === 0 ? 'url(/images/red.png)' : 'url(/images/green.png)',
            //},
            data: user.generations.map((generation, index) => {
              const { snapshots: [snapshot] } = generation;
              let date = new Date(generation.inserted_at.split('T')[0]);
              date = Date.UTC(date.getFullYear(), date.getMonth(), date.getDate());
              let data = null;
              if (snapshot) {
                if (stat === 0) {
                  data = snapshot.pp_raw;
                } else {
                  data = snapshot.playcount;
                }
              }
              return [
                date,
                data,
              ];
            })
          };
        })
      });
    });
  }

  handleOnChangePlayer1Value({ target: { value } }) {
    this.setState({
      player1: value,
    });
  }

  handleOnChangePlayer2Value({ target: { value } }) {
    this.setState({
      player2: value,
    });
  }

  handleOnClickUpdate() {
    this._initHighChart();
  }

  handleOnClickPP(stat) {
    this.setState({
      stat: 0,
    });
    this._initHighChart(0);
  }

  handleOnClickPlaycount() {
    this.setState({
      stat: 1,
    });
    this._initHighChart(1);
  }

  render() {
    const style = this.props.visible ? {} : { display: 'none' };
    return (
      <div style={style}>
        <div className='ui form'>
          <div className='inline fields'>
            <div className='field'>
              <div className='ui radio checkbox'>
                <input onChange={this.handleOnClickPP.bind(this)} type='radio' name='frequency' checked={this.state.stat === 0} />
                <label>PP</label>
              </div>
            </div>
            <div className='field'>
              <div className='ui radio checkbox'>
                <input onChange={this.handleOnClickPlaycount.bind(this)} type='radio' name='frequency' checked={this.state.stat === 1} />
                <label>Playcount</label>
              </div>
            </div>
          </div>
        </div>
        <div>
          <div className='ui input'>
            <input
              type='text'
              placeholder='Player 1'
              onChange={this.handleOnChangePlayer1Value.bind(this)}
              value={this.state.player1} />
          </div>
          <div className='ui input'>
            <input
              type='text'
              placeholder='Player 2'
              onChange={this.handleOnChangePlayer2Value.bind(this)}
              value={this.state.player2} />
          </div>
          <div
            className='ui button'
            onClick={this.handleOnClickUpdate.bind(this)}>
            Update
          </div>
        </div>
        <div id='container'>
        </div>
      </div>
    );
  }
}


class Scores extends Component {
  constructor(props) {
    super(props);
    this.state = {
      data: []
    };
  }

  componentDidMount() {
    const root = location.protocol + '//' + location.host;
    $.get(`${root}/api/latest-scores`, (data) => {
      this.setState({
        data,
      });
    });
  }

  render() {
    if (!this.props.visible) {
      return null;
    }

    return (
      <div>
        <h2 className='ui header'>
          January 2016 Scores
        </h2>
        <div className='ui list'>
          {this.state.data.map((user, index) => {
            return (
              <div className='item' key={index}>
                {user.username}
                <div className='list'>
                  {user.scores.map((score, scoreIndex) => {
                    const scoreDate = new Date(score.date);
                    return (
                      <div className='item' key={scoreIndex}>
                        [<strong>{score.pp}pp</strong>] <strong>{getModsArray(score.enabled_mods).join('')}</strong> {score.beatmap.artist} - {score.beatmap.title} [{score.beatmap.version}] \\ {score.beatmap.creator} - {scoreDate.toLocaleString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' })}
                      </div>
                    );
                  })}
                </div>
              </div>
            );
          })}
        </div>
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
      snapshots: [],
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

  handleMenuItemSelection(index) {
    this.setState({
      selectedTabIndex: index,
    });
  }

  render() {
    const { selectedTabIndex } = this.state;

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
          <Players
            players={this.state.players}
            visible={selectedTabIndex === 0} />
          <Scores
            visible={selectedTabIndex === 1} />
          <PlayerCharts
            snapshots={this.state.snapshots}
            visible={selectedTabIndex === 2} />
          {selectedTabIndex === 3 ?
            <Beatmaps
              beatmaps={this.state.beatmaps}
              onRowSelection={this.handleOnRowSelection.bind(this)}
              selectedBeatmapIndex={this.state.selectedBeatmapIndex} />
          : null}
        </div>
      </div>
    )
  }
}
