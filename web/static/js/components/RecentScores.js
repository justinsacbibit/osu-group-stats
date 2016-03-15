import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import {
  beatmapLink,
  getModsArray,
  momentFromOsuDate,
  userLink,
} from '../utils';

import {
  fetchRecentScores,
} from '../actions';


function formatBeatmapString(beatmap) {
  return `${beatmap.artist} - ${beatmap.title} [${beatmap.version}]`;
}

class RecentScores extends React.Component {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    groupId: PropTypes.string.isRequired,
    isLoading: PropTypes.bool.isRequired,
    scores: PropTypes.array.isRequired,
  };

  componentDidMount() {
    const {
      dispatch,
      groupId,
    } = this.props;

    dispatch(fetchRecentScores(groupId));
  }

  render() {
    return (
      <div>
        <div className='ui list'>
          {this.props.scores.map((score, index) => {
            const scoreMoment = momentFromOsuDate(score.date);
            const modsString = score.enabled_mods > 0 ? ` +${getModsArray(score.enabled_mods).join(',')}` : ``;
            return (
              <div className='item' key={index}>
                <a href={userLink(score.user.id, score.beatmap.mode)}>{score.user.username}</a> achieved <strong>{score.pp.toFixed(2)}pp</strong> on <a href={beatmapLink(score.beatmap.id, score.beatmap.mode)}>{formatBeatmapString(score.beatmap)}</a><strong>{modsString}</strong> <span style={{ textDecoration: 'underline' }} title={scoreMoment.format()}>{scoreMoment.fromNow()}</span>
              </div>
            );
          })}
        </div>
      </div>
    );
  }
}

function select(state) {
  return {
    isLoading: state.recentScores.isLoading,
    scores: state.recentScores.scores,
  };
}

export default connect(select)(RecentScores);

