import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import classNames from 'classnames';

import {
  fetchFarmedBeatmaps,
  selectFarmedBeatmap,
} from '../actions';
import Loader, { LOADER_SIZES } from '../components/Loader';
import { getModsArray } from '../utils';


class FarmedBeatmaps extends React.Component {
  static propTypes = {
    beatmaps: PropTypes.array.isRequired,
    dispatch: PropTypes.func.isRequired,
    groupId: PropTypes.string.isRequired,
    isLoading: PropTypes.bool.isRequired,
    selectedBeatmapIndex: PropTypes.number,
  };

  componentDidMount() {
    const {
      dispatch,
      groupId,
    } = this.props;

    dispatch(fetchFarmedBeatmaps(groupId));
  }

  handleOnRowSelection(selectedRow) {
    this.props.dispatch(selectFarmedBeatmap(selectedRow));
  }

  render() {
    const {
      beatmaps,
      isLoading,
      selectedBeatmapIndex,
    } = this.props;

    if (isLoading) {
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
                  const rowClassNames = classNames({
                    'active': index === this.props.selectedBeatmapIndex,
                  });
                  return (
                    <tr
                      className={rowClassNames}
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
                        {beatmap.artist} - {beatmap.title} [{beatmap.version}]
                        \\ {beatmap.creator}
                      </td>
                    </tr>
                    );
                })}
              </tbody>
            </table>

          </div>
          <div className='eight wide column'>
            {selectedBeatmapIndex !== null ?
             (() => {
               const selectedBeatmap = beatmaps[selectedBeatmapIndex];

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

                       const date = scoreDate.toLocaleString('en-US', {
                         year: 'numeric',
                         month: 'numeric',
                         day: 'numeric',
                       });

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
                             {date}
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

function select({ farmedBeatmaps: state }) {
  return {
    beatmaps: state.beatmaps,
    isLoading: state.isLoading,
    selectedBeatmapIndex: state.selectedBeatmapIndex,
  };
}

export default connect(select)(FarmedBeatmaps);

