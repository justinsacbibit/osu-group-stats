import React, { PropTypes } from 'react';

import TopPlayersByStat from './TopPlayersByStat';


export default class InfoPanel extends React.Component {
  static propTypes = {
    groupId: PropTypes.string.isRequired,
  };

  render() {
    return (
      <div className='ui horizontal segments'>
        <div className='ui segment'>
          <TopPlayersByStat
          />
        </div>
        <div className='ui segment'>
          b
        </div>
        <div className='ui segment'>
          c
        </div>
      </div>
    );
  }
}

