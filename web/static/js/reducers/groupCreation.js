import { combineReducers } from 'redux';

import {
  CREATE_GROUP_FAILURE,
  CREATE_GROUP_REQUEST,
  CREATE_GROUP_SUCCESS,
} from '../actions';

function error(state = null, event) {
  switch (event.type) {
    case CREATE_GROUP_REQUEST:
      return null;

    case CREATE_GROUP_FAILURE:
      return event.payload.error;
  }

  return state;
}

function isLoading(state = false, event) {
  switch (event.type) {
    case CREATE_GROUP_REQUEST:
      return true;

    case CREATE_GROUP_FAILURE:
      return false;

    case CREATE_GROUP_SUCCESS:
      return false;
  }

  return state;
}

export default combineReducers({
  error,
  isLoading,
});
