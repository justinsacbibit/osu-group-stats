import { combineReducers } from 'redux';

import {
  FETCH_PLAYERS_FAILURE,
  FETCH_PLAYERS_REQUEST,
  FETCH_PLAYERS_SUCCESS,
} from '../actions';

function players(state = [], event) {
  switch (event.type) {
    case FETCH_PLAYERS_SUCCESS:
      return [].concat(event.payload.players);

    case FETCH_PLAYERS_REQUEST:
      return [];
  }

  return state;
}

function isLoading(state = false, event) {
  switch (event.type) {
    case FETCH_PLAYERS_REQUEST:
      return true;

    case FETCH_PLAYERS_FAILURE:
      return false;

    case FETCH_PLAYERS_SUCCESS:
      return false;
  }

  return state;
}

export default combineReducers({
  isLoading,
  players,
});


