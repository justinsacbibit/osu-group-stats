import { combineReducers } from 'redux';

import {
  FETCH_LATEST_SCORES_FAILURE,
  FETCH_LATEST_SCORES_REQUEST,
  FETCH_LATEST_SCORES_SUCCESS,
} from '../actions';

function scores(state = [], event) {
  switch (event.type) {
    case FETCH_LATEST_SCORES_SUCCESS:
      return [].concat(event.payload.scores);

    case FETCH_LATEST_SCORES_REQUEST:
      return [];
  }

  return state;
}

function isLoading(state = false, event) {
  switch (event.type) {
    case FETCH_LATEST_SCORES_REQUEST:
      return true;

    case FETCH_LATEST_SCORES_FAILURE:
      return false;

    case FETCH_LATEST_SCORES_SUCCESS:
      return false;
  }

  return state;
}

export default combineReducers({
  isLoading,
  scores,
});

