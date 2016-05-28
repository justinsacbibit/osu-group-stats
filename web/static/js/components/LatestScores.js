import React, { PropTypes } from 'react';
import { connect } from 'react-redux';

import {
  fetchLatestScores,
} from '../actions';
import {
  getModsArray,
  momentFromOsuDate,
} from '../utils';


const before = '2016-06-01T00:00:00Z';
const since = '2016-05-01T00:00:00Z';

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
    } = this.props;

    dispatch(fetchLatestScores(groupId, before, since));
  }

  render() {
    return (
      <div>
        <h2 className='ui header'>
          May 2016 Scores
        </h2>
        <div className='ui list'>
          {this.props.scores.map((user, index) => {
            return (
              <div className='item' key={index}>
                {user.username}
                <div className='list'>
                  {user.scores.map((score, scoreIndex) => {
                    const scoreMoment = momentFromOsuDate(score.date);
                    return (
                      <div className='item' key={scoreIndex}>
                        [<strong>{score.pp}pp</strong>] <strong>{getModsArray(score.enabled_mods).join('')}</strong> {score.beatmap.artist} - {score.beatmap.title} [{score.beatmap.version}] \\ {score.beatmap.creator} - {scoreMoment.format('LL')}
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

