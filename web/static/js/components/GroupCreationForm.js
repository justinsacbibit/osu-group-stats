import React, { PropTypes } from 'react';
import classNames from 'classnames';
import { reduxForm } from 'redux-form';

import { createGroup } from '../actions';
import { MODES } from '../constants/osu';
import Dropdown from './Dropdown';
import DropdownItem from './DropdownItem';

const validate = values => {
  const errors = {};
  if (!values.name) {
    errors.name = 'Required';
  } else if (values.name.length < 3) {
    errors.name = 'Must be 3 characters or more';
  } else if (values.name.length > 20) {
    errors.name = 'Must be 15 characters or less';
  }
  if (!values.token) {
    errors.token = 'Required';
  } else if (values.token.length !== 8) {
    errors.token = 'Invalid token';
  }
  if (!values.players) {
    errors.players = 'Required';
  } else if (values.players[0] === ',') {
    errors.players = 'Should not start with a comma';
  } else if (values.players[values.players.length - 1] === ',') {
    errors.players = 'Should not end with a comma';
  }
  return errors;
};

class GroupCreationForm extends React.Component {
  static propTypes = {
    creationError: PropTypes.any,
    dispatch: PropTypes.func.isRequired,
    fields: PropTypes.object.isRequired,
    handleSubmit: PropTypes.func.isRequired,
    urlToken: PropTypes.string,
  };

  handleSubmit(group) {
    group.players = group.players.split(',');
    group.title = group.name;
    group.mode = MODES.findIndex(mode => mode === group.mode);
    this.props.dispatch(createGroup(group));
  }

  render() {
    const { fields: { mode, name, players, token }, handleSubmit } = this.props;
    const { creationError } = this.props;
    return (
      <form className='ui form' onSubmit={handleSubmit(this.handleSubmit.bind(this))}>
        <div className={classNames('field', { 'has-error': name.error })}>
          <label>Name</label>
          <div>
            <input type='text' placeholder='Name' {...name} />
          </div>
          {name.touched && name.error && <div>{name.error}</div>}
        </div>
        <div className={classNames('field', { 'has-error': token.error })}>
          <label>Token (get one by messaging "influxd" on osu! with a "!token" message)</label>
          <div>
            <input type='text' placeholder='Token' {...token} />
          </div>
          {token.touched && token.error && <div>{token.error}</div>}
        </div>
        <div className={classNames('field', { 'has-error': players.error })}>
          <label>Players (comma-separated, e.g. "Rafis,Cookiezi,hvick225")</label>
          <div>
            <input type='text' placeholder='Players' {...players} />
          </div>
          {players.touched && players.error && <div>{players.error}</div>}
        </div>
        <div className='field'>
          <label>Mode</label>
          <div>
            <Dropdown
              defaultText='Mode'
              id='mode'
              onChange={mode.onChange}
              value={mode.value}>
              {MODES.map((mode, index) => {
                return (
                  <DropdownItem
                    key={index}
                    value={mode}>
                    {mode}
                  </DropdownItem>
                );
              })}
            </Dropdown>
          </div>
        </div>
        <div className={classNames({ 'has-error': creationError })}>
          {creationError && <div>{`${creationError.response && creationError.response.body}` || 'Error..'}</div>}
        </div>
        <button className='ui submit button' type='submit'>Submit</button>
      </form>
    );
  }
}

function select(state) {
  return {
    creationError: state.groupCreation.error,
    initialValues: {
      mode: MODES[0],
      token: state.routing.location.query.t,
    },
    isLoading: state.groupCreation.isLoading,
  };
}

GroupCreationForm = reduxForm({
  form: 'groupCreation',
  fields: ['mode', 'name', 'token', 'players'],
  initialValues: {
    mode: MODES[0],
  },
  validate,
}, select)(GroupCreationForm);

export default GroupCreationForm;
