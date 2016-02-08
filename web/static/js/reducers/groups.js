import { combineReducers } from 'redux';

import {
  FETCH_GROUPS_FAILURE,
  FETCH_GROUPS_REQUEST,
  FETCH_GROUPS_SUCCESS,
} from '../actions';

function groups(state = [], event) {
  switch (event.type) {
    case FETCH_GROUPS_SUCCESS:
      return [].concat(event.payload.groups);

    case FETCH_GROUPS_REQUEST:
      return [];
  }

  return state;
}

function isLoading(state = false, event) {
  switch (event.type) {
    case FETCH_GROUPS_REQUEST:
      return true;

    case FETCH_GROUPS_FAILURE:
      return false;

    case FETCH_GROUPS_SUCCESS:
      return false;
  }

  return state;
}

export default combineReducers({
  isLoading,
  groups,
});

