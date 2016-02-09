import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
// TODO: Uncomment when Highcharts > 4.2.2 is released
// import Highcharts from 'highcharts';

import Chart from './Chart';
import StatsChartOptions from './StatsChartOptions';

import {
  addStatsChartPlayer,
  changeStatsChartPlayers,
  changeStatsChartShowDeltas,
  changeStatsChartStat,
  fetchDailySnapshots,
  removeStatsChartPlayer,
} from '../actions';
import { STATS } from '../constants/statsChart';

function buildHighChartOptions(dailySnapshots, players, selectedStat, showDeltas) {
  const filteredData = dailySnapshots.filter(data => players.map(username => username.toLowerCase()).indexOf(data.username.toLowerCase()) >= 0);
  const { text } = STATS.find(stat => stat.value === selectedStat);
  const series = filteredData.map(computeSeries.bind(this, showDeltas, selectedStat));

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

function computeSeries(showDeltas, selectedStat, user) {
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
      dispatch,
      groupId,
    } = this.props;

    dispatch(fetchDailySnapshots(groupId));
  }

  componentWillUnmount() {
    this.props.dispatch(changeStatsChartPlayers([]));
  }

  handleOnChangeSelectedStat(e) {
    this.props.dispatch(changeStatsChartStat(e));
  }

  handleOnAddSelectedPlayer(e) {
    const {
      dailySnapshots,
      dispatch,
      selectedStat,
      showDeltas,
    } = this.props;
    const { chart } = this.refs;

    if (chart) {
      chart.chart.addSeries(computeSeries(showDeltas, selectedStat, dailySnapshots.find(player => player.username === e)));
    }
    dispatch(addStatsChartPlayer(e));
  }

  handleOnRemoveSelectedPlayer(e) {
    const { chart } = this.refs;
    if (chart) {
      chart.chart.series.find(series => series.name === e).remove();
    }
    this.props.dispatch(removeStatsChartPlayer(e));
  }

  handleOnClickShowDeltas() {
    this.props.dispatch(changeStatsChartShowDeltas());
  }

  render() {
    const {
      dailySnapshots,
      players,
      selectedStat,
      showDeltas,
    } = this.props;
    const style = this.props.visible ? {} : { display: 'none' };

    return (
      <div style={style}>
        <StatsChartOptions
          onAddPlayer={this.handleOnAddSelectedPlayer.bind(this)}
          onChangeSelectedStat={this.handleOnChangeSelectedStat.bind(this)}
          onChangeShowDeltas={this.handleOnClickShowDeltas.bind(this)}
          onRemovePlayer={this.handleOnRemoveSelectedPlayer.bind(this)}
          players={this.props.dailySnapshots.map(snapshot => snapshot.username)}
          selectedPlayers={this.props.players}
          selectedStat={this.props.selectedStat}
          showDeltas={this.props.showDeltas}
        />
        {(this.props.visible || this.refs.chart) && this.props.dailySnapshots.length ?
          <Chart
            container='chart'
            options={buildHighChartOptions(dailySnapshots, players, selectedStat, showDeltas)}
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

