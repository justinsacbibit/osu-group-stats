import { combineReducers, createStore, applyMiddleware, compose } from 'redux';
import { persistState } from 'redux-devtools';
import thunkMiddleware from 'redux-thunk';
import createLogger from 'redux-logger';
import { syncHistory, routeReducer } from 'react-router-redux';
import { browserHistory } from 'react-router';
import rootReducer from '../reducers/reducers';
import DevTools from '../containers/DevTools';
import { reducer as formReducer } from 'redux-form';

const reducer = combineReducers(Object.assign({}, rootReducer, {
  form: formReducer,
  routing: routeReducer,
}));

// Sync dispatched route actions to the history
const reduxRouterMiddleware = syncHistory(browserHistory);

const enhancer = compose(
  // Middleware you want to use in development:
  applyMiddleware(thunkMiddleware, reduxRouterMiddleware, createLogger()),
  // Required! Enable Redux DevTools with the monitors you chose
  DevTools.instrument(),
  // Optional. Lets you write ?debug_session=<key> in address bar to persist debug sessions
  persistState(getDebugSessionKey())
);

function getDebugSessionKey() {
  // You can write custom logic here!
  // By default we try to read the key from ?debug_session=<key> in the address bar
  const matches = window.location.href.match(/[?&]debug_session=([^&]+)\b/);
  return (matches && matches.length > 0)? matches[1] : null;
}

export default function configureStore(initialState) {
  // Note: only Redux >= 3.1.0 supports passing enhancer as third argument.
  // See https://github.com/rackt/redux/releases/tag/v3.1.0
  const store = createStore(reducer, initialState, enhancer);

  // Required for replaying actions from devtools to work
  reduxRouterMiddleware.listenForReplays(store);

  // Hot reload reducers (requires Webpack or Browserify HMR to be enabled)
  if (module.hot) {
    module.hot.accept('../reducers', () =>
      store.replaceReducer(require('../reducers')/*.default if you use Babel 6+ */)
    );
  }

  return store;
}

