import React, { PropTypes } from 'react';


export default class DropdownItem extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    value: PropTypes.string.isRequired,
  };

  render() {
    return (
      <div
        className='item'
        data-value={this.props.value}>
        {this.props.children}
      </div>
    );
  }
}

