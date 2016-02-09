import React, { PropTypes } from 'react';

import Dropdown, { DROPDOWN_TYPES } from './Dropdown';
import DropdownItem from './DropdownItem';
import Slider from './Slider';

import { STATS } from '../constants/statsChart';


export default class StatsChartOptions extends React.Component {
  static propTypes = {
    onAddPlayer: PropTypes.func.isRequired,
    onChangeSelectedStat: PropTypes.func.isRequired,
    onChangeShowDeltas: PropTypes.func.isRequired,
    onRemovePlayer: PropTypes.func.isRequired,
    players: PropTypes.array.isRequired,
    selectedPlayers: PropTypes.array.isRequired,
    selectedStat: PropTypes.string.isRequired,
    showDeltas: PropTypes.bool.isRequired,
  };

  render() {
    return (
      <div className='ui form'>
        <div className='inline fields'>
          <div className='field'>
            <Dropdown
              defaultText='Select Players'
              id='players'
              onAdd={this.props.onAddPlayer}
              onRemove={this.props.onRemovePlayer}
              type={DROPDOWN_TYPES.MULTIPLE_SEARCH_NORMAL}
              value={this.props.selectedPlayers}>

              {this.props.players.map((username, index) => {
                return (
                  <DropdownItem
                    key={index}
                    value={username}>
                    {username}
                  </DropdownItem>
                );
              })}
            </Dropdown>
          </div>
          <div className='field'>
            <Dropdown
              defaultText='Stat'
              id='stat'
              onChange={this.props.onChangeSelectedStat}
              value={this.props.selectedStat}>
              {STATS.map((stat, index) => {
                return (
                  <DropdownItem
                    key={index}
                    value={stat.value}>
                    {stat.text}
                  </DropdownItem>
                );
              })}
            </Dropdown>
          </div>
          <div className='field'>
            <Slider
              id='showDeltas'
              onChange={this.props.onChangeShowDeltas}
              value={this.props.showDeltas}>

              <label>Show daily deltas</label>
            </Slider>
          </div>
        </div>
      </div>
    );
  }
}

