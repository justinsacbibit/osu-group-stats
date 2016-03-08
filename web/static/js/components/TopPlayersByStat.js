import React, { PropTypes } from 'react';


export default class TopPlayersByStat extends React.Component {
  static propTypes = {

  };

  render() {
    const data = [
      {
        header: 'Highest PP',
        player: 'Ciao',
        value: '7200',
      },
      {
        header: 'Highest Accuracy',
        player: 'Syl',
        value: '99.9999%',
      },
      {
        header: 'Most Improved',
        player: 'Eir Aoi',
        value: '400 pp over past 30 days',
      },
    ];

    return (
      <div>
        {data.map(({header, player, value}, index) => {
          return (
            <h3
              className='ui header'
              key={index}>
              <div className='content'>
                {header}
                <div className='sub header'>
                  {player} - <strong>{value}</strong>
                </div>
              </div>
            </h3>
          );
        })}
      </div>
    );
  }
}

