import { combineReducers } from 'redux';

import {
  FETCH_RECENT_SCORES_FAILURE,
  FETCH_RECENT_SCORES_REQUEST,
  FETCH_RECENT_SCORES_SUCCESS,
} from '../actions';

function scores(state = [], event) {
  switch (event.type) {
    case FETCH_RECENT_SCORES_SUCCESS:
      return [].concat(event.payload.scores);

    case FETCH_RECENT_SCORES_REQUEST:
      return [];
  }

  return state;
}

function isLoading(state = false, event) {
  switch (event.type) {
    case FETCH_RECENT_SCORES_REQUEST:
      return true;

    case FETCH_RECENT_SCORES_FAILURE:
      return false;

    case FETCH_RECENT_SCORES_SUCCESS:
      return false;
  }

  return state;
}

export default combineReducers({
  isLoading,
  scores,
});

