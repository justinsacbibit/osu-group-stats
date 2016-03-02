import React, { PropTypes } from 'react';
import { connect } from 'react-redux';

import GroupCreationForm from './GroupCreationForm';


class GroupCreation extends React.Component {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
  };

  render() {
    return (
      <div>
        <GroupCreationForm />
      </div>
    );
  }
}

export default connect()(GroupCreation);
