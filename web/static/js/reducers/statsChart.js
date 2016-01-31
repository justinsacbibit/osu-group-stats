import { combineReducers } from 'redux';

import {
  FETCH_DAILY_SNAPSHOTS_FAILURE,
  FETCH_DAILY_SNAPSHOTS_REQUEST,
  FETCH_DAILY_SNAPSHOTS_SUCCESS,
  CHANGED_STATS_CHART_ADD_PLAYER_INPUT_VALUE,
  ADDED_STATS_CHART_PLAYER,
  REMOVED_STATS_CHART_PLAYER,
  CHANGED_STATS_CHART_STAT,
  CHANGED_STATS_CHART_SHOW_DELTAS,
} from '../actions';
import { STAT_TYPES } from '../constants';

function addPlayerInputValue(state = '', event) {
  switch (event.type) {
    case CHANGED_STATS_CHART_ADD_PLAYER_INPUT_VALUE:
      return event.payload.value;

    case ADDED_STATS_CHART_PLAYER:
      return '';
  }

  return state;
}

function dailySnapshots(state = [], event) {
  switch (event.type) {
    case FETCH_DAILY_SNAPSHOTS_SUCCESS:
      return [].concat(event.payload.dailySnapshots);

    case FETCH_DAILY_SNAPSHOTS_REQUEST:
      return [];
  }

  return state;
}

function isLoading(state = false, event) {
  switch (event.type) {
    case FETCH_DAILY_SNAPSHOTS_REQUEST:
      return true;

    case FETCH_DAILY_SNAPSHOTS_FAILURE:
      return false;

    case FETCH_DAILY_SNAPSHOTS_SUCCESS:
      return false;
  }

  return state;
}

function players(state = [], event) {
  switch (event.type) {
    case FETCH_DAILY_SNAPSHOTS_SUCCESS:
      return event.payload.dailySnapshots.slice(0, 3).map(user => user.username);

    case ADDED_STATS_CHART_PLAYER:
      return state.concat([event.payload.player]);

    case REMOVED_STATS_CHART_PLAYER:
      const newPlayers = [].concat(state);
      newPlayers.splice(event.payload.index, 1);
      return newPlayers;
  }

  return state;
}

function selectedStat(state = STAT_TYPES.PP, event) {
  switch (event.type) {
    case CHANGED_STATS_CHART_STAT:
      return event.payload.stat;
  }

  return state;
}

function showDeltas(state = false, event) {
  switch (event.type) {
    case CHANGED_STATS_CHART_SHOW_DELTAS:
      return !state;
  }

  return state;
}

export default combineReducers({
  addPlayerInputValue,
  dailySnapshots,
  isLoading,
  players,
  selectedStat,
  showDeltas,
});

