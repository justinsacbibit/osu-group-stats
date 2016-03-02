import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { routeActions } from 'react-router-redux';

import {
  goToCreateGroup,
  goToFaq,
} from '../actions';


class TopBar extends React.Component {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    params: PropTypes.object.isRequired,
  };

  handleOnClickHome() {
    this.props.dispatch(routeActions.push(''));
  }

  handleOnClickFaq() {
    this.props.dispatch(goToFaq());
  }

  handleOnClickCreateGroup() {
    this.props.dispatch(goToCreateGroup());
  }

  render() {
    return (
      <div className='ui fixed inverted menu'>
        <div className='ui container'>
          <a
            className='header item'
            onClick={this.handleOnClickHome.bind(this)}>
            osu! Group Stats
          </a>
          <a
            className='item'
            onClick={this.handleOnClickFaq.bind(this)}>
            FAQ
          </a>
          <a
            className='item'
            onClick={this.handleOnClickCreateGroup.bind(this)}>
            Add a new group
          </a>
        </div>
      </div>
    );
  }
}

export default connect(() => ({}))(TopBar);

