import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import Highcharts from 'highcharts';

import {
  addStatsChartPlayer,
  changeStatsChartAddPlayerInput,
  changeStatsChartShowDeltas,
  changeStatsChartStat,
  fetchDailySnapshots,
  removeStatsChartPlayer,
} from '../actions';

const stats = [
  {
    text: 'Performance Points',
    value: 'pp_raw',
  },
  {
    text: 'Play Count',
    value: 'playcount',
  },
  {
    text: 'Total Score',
    value: 'total_score',
  },
  {
    text: 'Ranked Score',
    value: 'ranked_score',
  },
  {
    text: 'PP Rank',
    value: 'pp_rank',
  },
  {
    text: 'PP Country Rank',
    value: 'pp_country_rank',
  },
  {
    text: 'Level',
    value: 'level',
  },
  {
    text: 'Accuracy',
    value: 'accuracy',
  },
];


class Chart extends React.Component {
  static propTypes = {
    container: PropTypes.string.isRequired,
    options: PropTypes.object.isRequired,
    type: PropTypes.string,
  };
  static defaultProps = {
    type: 'chart',
  };

  componentDidMount() {
    this.chart = Highcharts[this.props.type](
      this.props.container,
      this.props.options
    );
    this.chart.reflow();
  }

  componentDidUpdate(prevProps) {
    if (prevProps.options.title.text !== this.props.options.title.text) {
      this.chart.setTitle(this.props.options.title);
      this.chart.yAxis[0].setTitle({
        text: this.props.options.yAxis.title.text,
      });
      const removed = this.chart.series.filter(series => this.props.options.series.indexOf(series) < 0);
      removed.forEach(series => series.remove());
      const added = this.props.options.series.filter(series => this.chart.series.indexOf(series) < 0);
      added.forEach(series => this.chart.addSeries(series));
    }
  }

  componentWillUnmount() {
    this.chart.destroy();
  }

  render() {
    return (
      <div id={this.props.container} />
    );
  }
}

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

    $('.ui.dropdown.stat').dropdown('set selected', 'pp_raw'); // eslint-disable-line no-undef
    $('.ui.dropdown.stat').dropdown({ // eslint-disable-line no-undef
      onChange: this.handleOnChangeSelectedStat.bind(this),
    });

    $('.ui.dropdown.players').dropdown({ // eslint-disable-line no-undef
      onAdd: this.handleOnAddSelectedPlayer.bind(this),
      onRemove: this.handleOnRemoveSelectedPlayer.bind(this),
    });
    $('.ui.dropdown.players') // eslint-disable-line no-undef
    .dropdown(
      'set selected',
      this.props.players
    );
  }

  computeSeries(showDeltas, selectedStat, user) {
    let series;
    if (!showDeltas) {
      const data = user.snapshots.map((snapshot) => {
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
      });
      series = {
        name: user.username,
        data,
      };
    } else {
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
      series = {
        name: user.username,
        data: res,
      };
    }
    return series;
  }

  buildHighChartOptions() {
    const {
      dailySnapshots,
      players,
      selectedStat,
      showDeltas,
    } = this.props;

    const filteredData = dailySnapshots.filter(data => players.map(username => username.toLowerCase()).indexOf(data.username.toLowerCase()) >= 0);
    const { text } = stats.find(stat => stat.value === selectedStat);
    const series = filteredData.map(this.computeSeries.bind(this, showDeltas, selectedStat));

    return {
      chart: {
        type: 'line',
        zoomType: 'x'
      },
      title: {
        text: showDeltas ? `${text} per day` : `${text} over time`,
      },
      subtitle: {
        text: document.ontouchstart === undefined ?
          'Click and drag in the plot area to zoom in' :
            'Pinch the chart to zoom in'
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
    };
  }

  handleOnChangeSelectedStat(e) {
    this.props.dispatch(changeStatsChartStat(e));
  }

  handleOnAddSelectedPlayer(e) {
    const {
      dailySnapshots,
      selectedStat,
      showDeltas,
    } = this.props;
    this.refs.chart.chart.addSeries(this.computeSeries(showDeltas, selectedStat, dailySnapshots.find(player => player.username === e)));
    this.props.dispatch(addStatsChartPlayer(e));
  }

  handleOnRemoveSelectedPlayer(e) {
    this.refs.chart.chart.series.find(series => series.name === e).remove();
    this.props.dispatch(removeStatsChartPlayer(e));
  }

  handleOnClickShowDeltas() {
    this.props.dispatch(changeStatsChartShowDeltas());
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
    return (
      <div>
        <div className='ui form'>
          <div className='inline fields'>
            <div className='field'>
              <div className='ui multiple search normal selection dropdown players'>
                <input type='hidden' />
                <i className='dropdown icon'></i>
                <div className='default text'>Select Players</div>
                <div className='menu'>
                  {this.props.dailySnapshots.map((user, index) => {
                    const { username } = user;
                    return (
                      <div
                        className='item'
                        data-value={username}
                        key={index}>
                        {username}
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
            <div className='field'>
              <div className='ui selection dropdown stat'>
                <i className='dropdown icon' />
                <div className='default text'>Stat</div>
                <div className='menu'>
                  {stats.map((stat, index) => {
                    return (
                      <div
                        className='item'
                        data-value={stat.value}
                        key={index}>
                        {stat.text}
                      </div>
                    );
                  })}
                </div>
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
          </div>
        </div>
        {this.props.dailySnapshots.length ?
          <Chart
            container='chart'
            options={this.buildHighChartOptions()}
            ref='chart' />
        : null}
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

