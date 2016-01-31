import { combineReducers } from 'redux';

import {
  FETCH_FARMED_BEATMAPS_FAILURE,
  FETCH_FARMED_BEATMAPS_REQUEST,
  FETCH_FARMED_BEATMAPS_SUCCESS,
  SELECTED_FARMED_BEATMAP,
} from '../actions';

function beatmaps(state = [], event) {
  switch (event.type) {
    case FETCH_FARMED_BEATMAPS_SUCCESS:
      return [].concat(event.payload.beatmaps);

    case FETCH_FARMED_BEATMAPS_REQUEST:
      return [];
  }

  return state;
}

function isLoading(state = false, event) {
  switch (event.type) {
    case FETCH_FARMED_BEATMAPS_REQUEST:
      return true;

    case FETCH_FARMED_BEATMAPS_FAILURE:
      return false;

    case FETCH_FARMED_BEATMAPS_SUCCESS:
      return false;
  }

  return state;
}

function selectedBeatmapIndex(state = null, event) {
  switch (event.type) {
    case SELECTED_FARMED_BEATMAP:
      return event.payload.index;
  }

  return state;
}

export default combineReducers({
  beatmaps,
  isLoading,
  selectedBeatmapIndex,
});

