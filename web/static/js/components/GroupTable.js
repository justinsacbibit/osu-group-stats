import React, { PropTypes } from 'react';

import { MODES } from '../constants/osu';
import Loader, { LOADER_SIZES } from '../components/Loader';


export default class GroupTable extends React.Component {
  static propTypes = {
    groups: PropTypes.array.isRequired,
    isLoading: PropTypes.bool.isRequired,
    onClickGroup: PropTypes.func.isRequired,
  };

  render() {
    const { groups, onClickGroup } = this.props;

    if (this.props.isLoading) {
      return (
        <Loader
          active
          centered
          inline
          size={LOADER_SIZES.LARGE} />
      );
    }

    return (
      <div>
        {groups.map((group, index) => {
          return (
            <div
              className=''
              key={index}>
              <a
                className='ui link'
                href='#'
                onClick={() => onClickGroup(group.id)}>
                Group ID: {group.id} | Group Name: {group.title} | Group Mode: {MODES[group.mode]}
              </a>
            </div>
          );
        })}
      </div>
    );
  }
}
