import React, { PropTypes } from 'react';


export default class Link extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    onClick: PropTypes.func,
  };

  render() {
    return (
      <a href='#' onClick={this.props.onClick}>
        {this.props.children}
      </a>
    );
  }
}
