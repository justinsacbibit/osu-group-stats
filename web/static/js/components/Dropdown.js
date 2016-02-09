import React, { PropTypes } from 'react';


export const DROPDOWN_TYPES = Object.freeze({
  DEFAULT: '',
  MULTIPLE_SEARCH_NORMAL: 'multiple search normal',
});

export default class Dropdown extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    defaultText: PropTypes.string,
    id: PropTypes.string.isRequired,
    onAdd: PropTypes.func,
    onChange: PropTypes.func,
    onRemove: PropTypes.func,
    type: PropTypes.string,
    value: PropTypes.any.isRequired,
  };
  static defaultProps = {
    type: DROPDOWN_TYPES.DEFAULT,
  };

  componentDidMount() {
    const {
      id,
      onAdd,
      onChange,
      onRemove,
    } = this.props;

    this.dropdown = $(`.ui.dropdown.${id}`); // eslint-disable-line no-undef

    // Is this required? Is JQuery required?
    this.dropdown.dropdown('set selected', this.props.value);
    this.dropdown.dropdown({
      onAdd: onAdd ? onAdd : () => {},
      onChange: onChange ? onChange : () => {},
      onRemove: onRemove ? onRemove : () => {},
    });
  }

  componentDidUpdate(prevProps) {
    if (prevProps.value !== this.props.value) {
      //this.dropdown.dropdown('set exactly', this.props.value);
    }
  }

  render() {
    return (
      <div
        className={`ui ${this.props.type} selection dropdown ${this.props.id}`}>
        {this.props.type === DROPDOWN_TYPES.MULTIPLE_SEARCH_NORMAL ?
          <input type='hidden' />
        : null}
        <i className='dropdown icon' />
        <div className='default text'>{this.props.defaultText}</div>
        <div className='menu'>
          {this.props.children}
        </div>
      </div>
    );
  }
}

