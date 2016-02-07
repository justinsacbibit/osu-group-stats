import fetch from 'isomorphic-fetch';


export const FETCH_FARMED_BEATMAPS_REQUEST = 'FETCH_FARMED_BEATMAPS_REQUEST';
export const FETCH_FARMED_BEATMAPS_SUCCESS = 'FETCH_FARMED_BEATMAPS_SUCCESS';
export const FETCH_FARMED_BEATMAPS_FAILURE = 'FETCH_FARMED_BEATMAPS_FAILURE';
export const SELECTED_FARMED_BEATMAP = 'SELECTED_FARMED_BEATMAP';

export const FETCH_PLAYERS_FAILURE = 'FETCH_PLAYERS_FAILURE';
export const FETCH_PLAYERS_REQUEST = 'FETCH_PLAYERS_REQUEST';
export const FETCH_PLAYERS_SUCCESS = 'FETCH_PLAYERS_SUCCESS';

export const FETCH_DAILY_SNAPSHOTS_FAILURE = 'FETCH_DAILY_SNAPSHOTS_FAILURE';
export const FETCH_DAILY_SNAPSHOTS_REQUEST = 'FETCH_DAILY_SNAPSHOTS_REQUEST';
export const FETCH_DAILY_SNAPSHOTS_SUCCESS = 'FETCH_DAILY_SNAPSHOTS_SUCCESS';
export const CHANGED_STATS_CHART_ADD_PLAYER_INPUT_VALUE = 'CHANGED_STATS_CHART_ADD_PLAYER_INPUT_VALUE';
export const ADDED_STATS_CHART_PLAYER = 'ADDED_STATS_CHART_PLAYER';
export const REMOVED_STATS_CHART_PLAYER = 'REMOVED_STATS_CHART_PLAYER';
export const CHANGED_STATS_CHART_PLAYERS = 'CHANGED_STATS_CHART_PLAYERS';
export const CHANGED_STATS_CHART_STAT = 'CHANGED_STATS_CHART_STAT';
export const CHANGED_STATS_CHART_SHOW_DELTAS = 'CHANGED_STATS_CHART_SHOW_DELTAS';

export const FETCH_LATEST_SCORES_REQUEST = 'FETCH_LATEST_SCORES_REQUEST';
export const FETCH_LATEST_SCORES_SUCCESS = 'FETCH_LATEST_SCORES_SUCCESS';
export const FETCH_LATEST_SCORES_FAILURE = 'FETCH_LATEST_SCORES_FAILURE';

const root = location.protocol + '//' + location.host;

function fetchFarmedBeatmapsRequest(groupId) {
  return {
    payload: {
      groupId,
    },
    type: FETCH_FARMED_BEATMAPS_REQUEST,
  };
}

function fetchFarmedBeatmapsSuccess(beatmaps) {
  return {
    payload: {
      beatmaps,
    },
    type: FETCH_FARMED_BEATMAPS_SUCCESS,
  };
}

function fetchFarmedBeatmapsFailure(error) {
  return {
    payload: {
      error,
    },
    type: FETCH_FARMED_BEATMAPS_FAILURE,
  };
}

export function fetchFarmedBeatmaps(groupId) {
  return dispatch => {
    dispatch(fetchFarmedBeatmapsRequest(groupId));

    return fetch(`${root}/api/farmed-beatmaps?g=${groupId}`)
    .then(response => {
      if (response.status >= 400) {
        throw new Error();
      }
      return response.json();
    }).then(response => {
      return dispatch(fetchFarmedBeatmapsSuccess(response));
    }, error => {
      return dispatch(fetchFarmedBeatmapsFailure(error));
    });
  };
}

export function selectFarmedBeatmap(index) {
  return {
    payload: {
      index,
    },
    type: SELECTED_FARMED_BEATMAP,
  };
}

function fetchPlayersRequest(groupId) {
  return {
    payload: {
      groupId,
    },
    type: FETCH_PLAYERS_REQUEST,
  };
}

function fetchPlayersSuccess(players) {
  return {
    payload: {
      players,
    },
    type: FETCH_PLAYERS_SUCCESS,
  };
}

function fetchPlayersFailure(error) {
  return {
    payload: {
      error,
    },
    type: FETCH_PLAYERS_FAILURE,
  };
}

export function fetchPlayers(groupId) {
  return dispatch => {
    dispatch(fetchPlayersRequest(groupId));

    return fetch(`${root}/api/players?g=${groupId}`)
    .then(response => {
      if (response.status >= 400) {
        throw new Error();
      }
      return response.json();
    }).then(response => {
      return dispatch(fetchPlayersSuccess(response));
    }, error => {
      return dispatch(fetchPlayersFailure(error));
    });
  };
}

function fetchDailySnapshotsRequest(groupId) {
  return {
    payload: {
      groupId,
    },
    type: FETCH_DAILY_SNAPSHOTS_REQUEST,
  };
}

function fetchDailySnapshotsSuccess(dailySnapshots) {
  return {
    payload: {
      dailySnapshots,
    },
    type: FETCH_DAILY_SNAPSHOTS_SUCCESS,
  };
}

function fetchDailySnapshotsFailure(error) {
  return {
    payload: {
      error,
    },
    type: FETCH_DAILY_SNAPSHOTS_FAILURE,
  };
}

export function fetchDailySnapshots(groupId) {
  return dispatch => {
    dispatch(fetchDailySnapshotsRequest(groupId));

    return fetch(`${root}/api/daily-snapshots?g=${groupId}`)
    .then(response => {
      if (response.status >= 400) {
        throw new Error();
      }
      return response.json();
    }).then(response => {
      return dispatch(fetchDailySnapshotsSuccess(response));
    }, error => {
      return dispatch(fetchDailySnapshotsFailure(error));
    });
  };
}

export function changeStatsChartAddPlayerInput(value) {
  return {
    payload: {
      value,
    },
    type: CHANGED_STATS_CHART_ADD_PLAYER_INPUT_VALUE,
  };
}

export function addStatsChartPlayer(player) {
  return {
    payload: {
      player,
    },
    type: ADDED_STATS_CHART_PLAYER,
  };
}

export function removeStatsChartPlayer(index) {
  return {
    payload: {
      index,
    },
    type: REMOVED_STATS_CHART_PLAYER,
  };
}

export function changeStatsChartPlayers(players) {
  return {
    payload: {
      players,
    },
    type: CHANGED_STATS_CHART_PLAYERS,
  };
}

export function changeStatsChartStat(stat) {
  return {
    payload: {
      stat,
    },
    type: CHANGED_STATS_CHART_STAT,
  };
}

export function changeStatsChartShowDeltas() {
  return {
    payload: {},
    type: CHANGED_STATS_CHART_SHOW_DELTAS,
  };
}

function fetchLatestScoresRequest(groupId) {
  return {
    payload: {
      groupId,
    },
    type: FETCH_LATEST_SCORES_REQUEST,
  };
}

function fetchLatestScoresSuccess(scores) {
  return {
    payload: {
      scores,
    },
    type: FETCH_LATEST_SCORES_SUCCESS,
  };
}

function fetchLatestScoresFailure(error) {
  return {
    payload: {
      error,
    },
    type: FETCH_LATEST_SCORES_FAILURE,
  };
}

export function fetchLatestScores(groupId, before, since) {
  return dispatch => {
    dispatch(fetchLatestScoresRequest(groupId));

    return fetch(`${root}/api/latest-scores?g=${groupId}&before=${before}&since=${since}`)
    .then(response => {
      if (response.status >= 400) {
        throw new Error();
      }
      return response.json();
    }).then(response => {
      return dispatch(fetchLatestScoresSuccess(response));
    }, error => {
      return dispatch(fetchLatestScoresFailure(error));
    });
  };
}

