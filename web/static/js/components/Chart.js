import React, { PropTypes } from 'react';


export default class Chart extends React.Component {
  static propTypes = {
    container: PropTypes.string.isRequired,
    options: PropTypes.object.isRequired,
    type: PropTypes.string,
  };
  static defaultProps = {
    type: 'chart',
  };

  componentDidMount() {
    this.chart = Highcharts[this.props.type]( // eslint-disable-line no-undef
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

