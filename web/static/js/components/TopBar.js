import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { routeActions } from 'react-router-redux';


class TopBar extends React.Component {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    params: PropTypes.object.isRequired,
  };

  handleOnClickHome() {
    this.props.dispatch(routeActions.push(''));
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
        </div>
      </div>
    );
  }
}

export default connect(() => ({}))(TopBar);

