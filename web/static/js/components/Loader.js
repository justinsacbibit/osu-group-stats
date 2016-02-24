import React, { PropTypes } from 'react';
import classNames from 'classnames';


export const LOADER_SIZES = Object.freeze({
  LARGE: 'large',
});

export default class Loader extends React.Component {
  static propTypes = {
    active: PropTypes.bool,
    centered: PropTypes.bool,
    inline: PropTypes.bool,
    size: PropTypes.string,
  };

  render() {
    const classes = classNames('ui loader', {
      active: this.props.active,
      centered: this.props.centered,
      inline: this.props.inline,
      [this.props.size]: this.props.size,
    });
    return (
      <div className={classes} />
    );
  }
}

