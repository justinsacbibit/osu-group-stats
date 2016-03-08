import { combineReducers } from 'redux';

import {
  FETCH_GROUP_FAILURE,
  FETCH_GROUP_REQUEST,
  FETCH_GROUP_SUCCESS,
} from '../actions';

function group(state = null, event) {
  switch (event.type) {
    case FETCH_GROUP_SUCCESS:
      return event.payload.group;

    case FETCH_GROUP_REQUEST:
      return null;
  }

  return state;
}

function isLoading(state = false, event) {
  switch (event.type) {
    case FETCH_GROUP_REQUEST:
      return true;

    case FETCH_GROUP_FAILURE:
      return false;

    case FETCH_GROUP_SUCCESS:
      return false;
  }

  return state;
}

export default combineReducers({
  isLoading,
  group,
});

