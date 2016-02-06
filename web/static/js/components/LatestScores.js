import React, { PropTypes } from 'react';
import { connect } from 'react-redux';

import {
  fetchLatestScores,
} from '../actions';
import { getModsArray } from '../utils';


class LatestScores extends React.Component {
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
      scores,
    } = this.props;

    if (scores.length === 0) {
      dispatch(fetchLatestScores(groupId));
    }
  }

  render() {
    return (
      <div>
        <h2 className='ui header'>
          January 2016 Scores
        </h2>
        <div className='ui list'>
          {this.props.scores.map((user, index) => {
            return (
              <div className='item' key={index}>
                {user.username}
                <div className='list'>
                  {user.scores.map((score, scoreIndex) => {
                    const scoreDate = new Date(score.date);
                    return (
                      <div className='item' key={scoreIndex}>
                        [<strong>{score.pp}pp</strong>] <strong>{getModsArray(score.enabled_mods).join('')}</strong> {score.beatmap.artist} - {score.beatmap.title} [{score.beatmap.version}] \\ {score.beatmap.creator} - {scoreDate.toLocaleString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' })}
                      </div>
                    );
                  })}
                </div>
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
    isLoading: state.latestScores.isLoading,
    scores: state.latestScores.scores,
  };
}

export default connect(select)(LatestScores);
