import React, { PropTypes } from 'react';

import { MODES } from '../constants/osu';


export default class GroupHeader extends React.Component {
  static propTypes = {
    group: PropTypes.object.isRequired,
  };

  render() {
    const { group } = this.props;
    const insertedAt = new Date(group.inserted_at);


    return (
      <div>
        <div style={{ display: 'flex' }}>
          <h2 className='ui header' style={{ flex: 1, marginTop: 0 }}>
            <div className='content'>
              {group.title}
              <div className='sub header'>
                {MODES[group.mode]}
              </div>
            </div>
          </h2>
          <h2 className='ui header' style={{ marginTop: 0 }}>
            <div className='content' style={{ flexDirection: 'column', alignItems: 'flex-end', display: 'flex' }}>
              <span>
                {group.users.length} members
              </span>
              <div className='sub header' style={{ justifyContent: 'flex-end', flexDirection: 'row', display: 'flex' }}>
                Added on&nbsp;{insertedAt.toLocaleString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' })}
              </div>
            </div>
          </h2>
        </div>
      </div>
    );
  }
}

