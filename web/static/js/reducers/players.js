import { combineReducers } from 'redux';

import {
  CHANGED_PLAYER_TABLE_RECENT_CHANGES_STAT,
  CHANGED_PLAYER_TABLE_SHOW_RECENT_CHANGES,
  CHANGED_PLAYER_TABLE_SORT_ORDER,
  FETCH_PLAYERS_FAILURE,
  FETCH_PLAYERS_REQUEST,
  FETCH_PLAYERS_SUCCESS,
} from '../actions';
import { SORT_ORDERS } from '../constants';

const initialIsLoadingState = {
  0: false,
  1: false,
  30: false,
  7: false,
};
function isLoading(state = initialIsLoadingState, event) {
  switch (event.type) {
    case FETCH_PLAYERS_REQUEST:
      return Object.assign({}, state, {
        [event.payload.daysDelta]: true,
      });

    case FETCH_PLAYERS_FAILURE:
      return Object.assign({}, state, {
        [event.payload.daysDelta]: false,
      });

    case FETCH_PLAYERS_SUCCESS:
      return Object.assign({}, state, {
        [event.payload.daysDelta]: false,
      });
  }

  return state;
}

const initialPlayersState = {
  0: {},
  1: {},
  30: {},
  7: {},
};
function players(state = initialPlayersState, event) {
  switch (event.type) {
    case FETCH_PLAYERS_SUCCESS:
      const playerMap = {};
      event.payload.players.forEach(player => {
        playerMap[player.user_id] = player;
      });
      return Object.assign({}, state, {
        [event.payload.daysDelta]: playerMap,
      });

    case FETCH_PLAYERS_REQUEST:
      return Object.assign({}, state, {
        [event.payload.daysDelta]: {},
      });
  }

  return state;
}

const initialRecentChangesState = {
  show: false,
  stat: 'PP',
};
function recentChanges(state = initialRecentChangesState, event) {
  switch (event.type) {
    case CHANGED_PLAYER_TABLE_SHOW_RECENT_CHANGES:
      return {
        show: event.payload.showRecentChanges,
        stat: state.stat,
      };

    case CHANGED_PLAYER_TABLE_RECENT_CHANGES_STAT:
      return {
        show: state.show,
        stat: event.payload.stat,
      };

    case '@@router/UPDATE_LOCATION':
      return initialRecentChangesState;
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

    case CHANGED_PLAYER_TABLE_SHOW_RECENT_CHANGES:
      return initialSortOrderState;

    case '@@router/UPDATE_LOCATION':
      return initialSortOrderState;
  }

  return state;
}

export default combineReducers({
  isLoading,
  players,
  recentChanges,
  sortOrder,
});


