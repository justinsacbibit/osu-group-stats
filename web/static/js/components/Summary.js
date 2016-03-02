import React, { PropTypes } from 'react';
import { connect } from 'react-redux';


import {
  goToCreateGroup,
  goToFaq,
} from '../actions';
import Link from './Link';


export default class Summary extends React.Component {
  static propTypes = {
    dispatch: PropTypes.func.isRequired,
  };

  handleOnClickFaq() {
    this.props.dispatch(goToFaq());
  }

  handleOnClickCreateGroup() {
    this.props.dispatch(goToCreateGroup());
  }

  render() {
    return (
      <div>
        <h1>
          What is osu! Group Stats?
        </h1>
        <p>
          osu! Group Stats is an unofficial tool that shows information about
          groups of players, allowing you to compare their PP ranks,
          playcounts, etc. You can also see how they've changed over time.
          Visit the
          {' '}<Link onClick={this.handleOnClickFaq.bind(this)}>FAQ</Link>{' '}
          to learn more.
        </p>
        <p>
          Anyone can create their own groups - click
          {' '}<Link onClick={this.handleOnClickCreateGroup.bind(this)}>here</Link>{' '}
          to get started!
        </p>
      </div>
    );
  }
}

export default connect()(Summary);
