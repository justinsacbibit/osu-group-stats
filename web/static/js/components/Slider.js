import React, { PropTypes } from 'react';


export default class Slider extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    id: PropTypes.string.isRequired,
    onChange: PropTypes.func.isRequired,
    value: PropTypes.bool.isRequired,
  };

  componentDidMount() {
    this.checkbox = $(`.ui.checkbox.${this.props.id}`); // eslint-disable-line no-undef
    if (this.props.value) {
      this.checkbox.checkbox('set checked');
    }
    this.checkbox.checkbox({
      onChange: this.props.onChange,
    });
  }

  componentDidUpdate(prevProps) {
    if (prevProps.value !== this.props.value) {
      if (this.props.value) {
        this.checkbox.checkbox('set checked');
      } else {
        this.checkbox.checkbox('set unchecked');
      }
    }
  }

  render() {
    return (
      <div className={`ui slider checkbox ${this.props.id}`}>
        <input type='checkbox' />
        {this.props.children}
      </div>
    );
  }
}

