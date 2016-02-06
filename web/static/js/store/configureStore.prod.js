import { combineReducers, createStore, applyMiddleware } from 'redux';
import { syncHistory, routeReducer } from 'react-router-redux';
import { browserHistory } from 'react-router';
import thunkMiddleware from 'redux-thunk';
import rootReducer from '../reducers/reducers';

const reducer = combineReducers(Object.assign({}, rootReducer, {
  routing: routeReducer
}));

// Sync dispatched route actions to the history
const reduxRouterMiddleware = syncHistory(browserHistory);

// Middleware you want to use in production:
const enhancer = applyMiddleware(thunkMiddleware, reduxRouterMiddleware);

export default function configureStore(initialState) {
  // Note: only Redux >= 3.1.0 supports passing enhancer as third argument.
  // See https://github.com/rackt/redux/releases/tag/v3.1.0
  return createStore(reducer, initialState, enhancer);
};

