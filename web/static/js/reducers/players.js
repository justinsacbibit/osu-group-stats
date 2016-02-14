import { combineReducers } from 'redux';

import {
  CHANGED_PLAYER_TABLE_SORT_ORDER,
  FETCH_PLAYERS_FAILURE,
  FETCH_PLAYERS_REQUEST,
  FETCH_PLAYERS_SUCCESS,
} from '../actions';
import { SORT_ORDERS } from '../constants';

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

function players(state = [], event) {
  switch (event.type) {
    case FETCH_PLAYERS_SUCCESS:
      return [].concat(event.payload.players);

    case FETCH_PLAYERS_REQUEST:
      return [];
  }

  return state;
}

const initialSortOrderState = {
  direction: SORT_ORDERS.DESCENDING,
  index: 0,
};
function sortOrder(state = initialSortOrderState, event) {
  switch (event.type) {
    case CHANGED_PLAYER_TABLE_SORT_ORDER:
      let { direction } = state;
      const index = event.payload.index;
      if (index === state.index) {
        if (state.direction === SORT_ORDERS.ASCENDING) {
          direction = SORT_ORDERS.DESCENDING;
        } else {
          direction = SORT_ORDERS.ASCENDING;
        }
      } else {
        direction = SORT_ORDERS.DESCENDING;
      }
      return {
        direction,
        index,
      };
  }

  return state;
}

export default combineReducers({
  isLoading,
  players,
  sortOrder,
});


