import React, { PropTypes } from 'react';
import { connect } from 'react-redux';

import {
  fetchDailySnapshots,
  changeStatsChartShowDeltas,
  changeStatsChartStat,
  removeStatsChartPlayer,
  addStatsChartPlayer,
  changeStatsChartAddPlayerInput,
} from '../actions';
import { STAT_TYPES } from '../constants';


class StatsChart extends React.Component {
  static propTypes = {
    addPlayerInputValue: PropTypes.string.isRequired,
    dailySnapshots: PropTypes.array.isRequired,
    dispatch: PropTypes.func.isRequired,
    groupId: PropTypes.string.isRequired,
    isLoading: PropTypes.bool.isRequired,
    players: PropTypes.array.isRequired,
    selectedStat: PropTypes.string.isRequired,
    showDeltas: PropTypes.bool.isRequired,
    visible: PropTypes.bool.isRequired,
  };

  componentDidMount() {
    const {
      dailySnapshots,
      dispatch,
      groupId,
    } = this.props;

    if (dailySnapshots.length === 0) {
      dispatch(fetchDailySnapshots(groupId));
    }
  }

  componentDidUpdate(prevProps) {
    if (!prevProps.visible && this.props.visible && this.props.players.length > 0 && this.props.dailySnapshots.length > 0) {
      this._initHighChart();
    } else if (this.props.visible &&
                (prevProps.players !== this.props.players
                  || prevProps.dailySnapshots !== this.props.dailySnapshots
                    || prevProps.selectedStat !== this.props.selectedStat
                      || prevProps.showDeltas !== this.props.showDeltas)) {
      this._initHighChart();
    }
  }

  _initHighChart() {
    const {
      dailySnapshots,
      players,
      selectedStat,
    } = this.props;

    $(() => { // eslint-disable-line no-undef
      const filteredData = dailySnapshots.filter(data => players.map(username => username.toLowerCase()).indexOf(data.username.toLowerCase()) >= 0);
      const text = {
        [STAT_TYPES.PP]: 'Performance Points',
        [STAT_TYPES.PLAYCOUNT]: 'Play Count',
      }[selectedStat];
      let series;
      if (!this.props.showDeltas) {
        series = filteredData.map((user) => {
          return {
            name: user.username,
            data: user.snapshots.map((snapshot) => {
              let date = new Date(snapshot.inserted_at);
              date = Date.UTC(date.getFullYear(), date.getMonth(), date.getDate());
              let data = null;
              if (snapshot) {
                data = snapshot[selectedStat];
              }
              return [
                date,
                data,
              ];
            })
          };
        });
      } else {
        series = filteredData.map((user) => {
          const res = [];
          for (let i = 0; i < user.snapshots.length - 1; i++) {
            const d1 = user.snapshots[i];
            const d2 = user.snapshots[i+1];
            let date = new Date(d1.inserted_at);
            date = Date.UTC(date.getFullYear(), date.getMonth(), date.getDate());
            let data = null;
            if (d1 && d2) {
              data = d2[selectedStat] - d1[selectedStat];
            }
            res.push([date, data]);
          }
          return {
            name: user.username,
            data: res,
          };
        });
      }

      $('#container').highcharts({ // eslint-disable-line no-undef
        chart: {
          type: 'line'
        },
        title: {
          text,
        },
        xAxis: {
          type: 'datetime'
        },
        yAxis: {
          title: {
            text,
          }
        },
        series,
      });
    });
  }

  handleOnClickPP() {
    this.props.dispatch(changeStatsChartStat(STAT_TYPES.PP));
  }

  handleOnClickPlaycount() {
    this.props.dispatch(changeStatsChartStat(STAT_TYPES.PLAYCOUNT));
  }

  handleOnClickShowDeltas() {
    this.props.dispatch(changeStatsChartShowDeltas());
  }

  handleOnClickRemove(index) {
    this.props.dispatch(removeStatsChartPlayer(index));
  }

  handleOnAddPlayer(e) {
    if (e.key === 'Enter' && this.props.addPlayerInputValue.length > 0) {
      this.props.dispatch(addStatsChartPlayer(this.props.addPlayerInputValue));
    }
  }

  handleOnChangeAddPlayerValue(e) {
    this.props.dispatch(changeStatsChartAddPlayerInput(e.target.value));
  }

  render() {
    const style = this.props.visible ? {} : { display: 'none' };
    return (
      <div style={style}>
        <div className='ui form'>
          <div className='inline fields'>
            <div className='field'>
              <div className='ui radio checkbox'>
                <input onChange={this.handleOnClickPP.bind(this)} type='radio' name='frequency' checked={this.props.selectedStat === STAT_TYPES.PP} />
                <label>PP</label>
              </div>
            </div>
            <div className='field'>
              <div className='ui radio checkbox'>
                <input onChange={this.handleOnClickPlaycount.bind(this)} type='radio' name='frequency' checked={this.props.selectedStat === STAT_TYPES.PLAYCOUNT} />
                <label>Playcount</label>
              </div>
            </div>
            <div className='field'>
              <div className='ui slider checkbox'>
                <input
                  onChange={this.handleOnClickShowDeltas.bind(this)}
                  type='checkbox'
                  value={this.props.showDeltas} />
                <label>Show daily deltas</label>
              </div>
            </div>
            <div className='field'>
              <input
                type='text'
                placeholder='Add another player'
                onKeyUp={this.handleOnAddPlayer.bind(this)}
                value={this.props.addPlayerInputValue}
                onChange={this.handleOnChangeAddPlayerValue.bind(this)} />
            </div>
          </div>
          <div>
            <div className='ui blue labels'>
              {this.props.players.map((username, index) => {
                return (
                  <a className='ui label' key={index}>
                    {username} <i
                      className='icon close'
                      onClick={this.handleOnClickRemove.bind(this, index)} />
                  </a>
                  );
              })}
            </div>
          </div>
        </div>
        <div id='container'>
        </div>
      </div>
    );
  }
}

function select(state) {
  return {
    addPlayerInputValue: state.statsChart.addPlayerInputValue,
    dailySnapshots: state.statsChart.dailySnapshots,
    isLoading: state.statsChart.isLoading,
    players: state.statsChart.players,
    selectedStat: state.statsChart.selectedStat,
    showDeltas: state.statsChart.showDeltas,
  };
}

export default connect(select)(StatsChart);

