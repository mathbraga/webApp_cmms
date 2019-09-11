import React, { Component } from 'react';
import {
  FormGroup,
  Label,
  Input,
} from 'reactstrap';

import "./InputWithDropdown.css";

class SingleInputWithDropDown extends Component {
  constructor(props) {
    super(props);
    this.state = {
      inputValue: '',
      isDropdownOpen: false,
      hoveredItem: 0,
      chosenValue: '',
    }
    this.onChangeInput = this.onChangeInput.bind(this);
    this.toggleDropdown = this.toggleDropdown.bind(this);
    this.onHoverItem = this.onHoverItem.bind(this);
    this.onKeyDownInput = this.onKeyDownInput.bind(this);
    this.onRemoveItemFromList = this.onRemoveItemFromList.bind(this);
    this.onClickItem = this.onClickItem.bind(this);
    this.updateChosenValue = this.updateChosenValue.bind(this);
    this.arrayItems = {};
  }

  onChangeInput(event) {
    this.containerScroll.scrollTo(0, 0);
    this.setState({
      inputValue: event.target.value,
      hoveredItem: 0,
    });
  }

  toggleDropdown(isDropdownOpen) {
    this.setState(prevState => ({
      isDropdownOpen,
      inputValue: isDropdownOpen ? '' : prevState.inputValue,
      hoveredItem: isDropdownOpen ? 0 : prevState.hoveredItem,
      chosenValue: isDropdownOpen ? '' : prevState.chosenValue,
    }));
  }

  onHoverItem(index) {
    this.setState({
      hoveredItem: index,
    });
  }

  onKeyDownInput = (filteredList) => (event) => {
    const { hoveredItem } = this.state;
    const lengthList = filteredList.length;
    switch (event.keyCode) {
      case 40:
        this.setState(prevState => {
          if (prevState.hoveredItem === lengthList - 1) { return; }
          this.arrayItems[filteredList[hoveredItem + 1].id]
            .scrollIntoViewIfNeeded(false, { behavior: 'smooth' });
          return {
            hoveredItem: prevState.hoveredItem + 1
          }
        });
        break;
      case 38:
        this.setState(prevState => {
          if (prevState.hoveredItem === 0) { return; }
          this.arrayItems[filteredList[hoveredItem - 1].id]
            .scrollIntoViewIfNeeded(true, { behavior: 'smooth' });
          return {
            hoveredItem: prevState.hoveredItem - 1
          }
        });
        break;
      case 13:
        this.inputDrop.blur();
        this.setState(this.updateChosenValue(filteredList));
        break;
    }
  }

  onRemoveItemFromList(id) {
    this.setState(prevState => {
      const newList = prevState.chosenValue.filter(item =>
        item.id !== id);
      return {
        chosenValue: newList,
        hoveredItem: 0,
      };
    });
  }

  onClickItem = (filteredList) => () => {
    this.setState(this.updateChosenValue(filteredList));
  }

  updateChosenValue = (filteredList) => (prevState) => {
    if (prevState.hoveredItem < 0 || prevState.hoveredItem >= filteredList.length) {
      return {
        inputValue: "",
      };
    }
    const newValue = filteredList[prevState.hoveredItem].name;
    this.props.update(newValue);
    return {
      chosenValue: newValue,
      hoveredItem: 0,
      inputValue: newValue,
    };
  };

  render() {
    const { label, placeholder, listDropdown } = this.props;
    const { inputValue, isDropdownOpen, hoveredItem } = this.state;
    const filteredList = listDropdown.filter((item) =>
      (
        item.name.toLowerCase().includes(inputValue.toLowerCase())
      ));
    console.log(this.state.inputValue);
    return (
      <FormGroup className={'dropdown-container'}>
        <Label htmlFor="input">{label}</Label>
        <Input
          type="text"
          autoComplete="off"
          id="input"
          value={inputValue}
          placeholder={placeholder}
          onChange={this.onChangeInput}
          onFocus={() => this.toggleDropdown(true)}
          onBlur={() => this.toggleDropdown(false)}
          onKeyDown={this.onKeyDownInput(filteredList)}
          innerRef={(el) => { this.inputDrop = el; }}
        />
        {isDropdownOpen && (
          <div
            className="dropdown-input"
            ref={(el) => { this.containerScroll = el }}
          >
            <ul>
              {filteredList.map((item, index) => (
                <li
                  key={item.id}
                  id={item.id}
                  onMouseOver={() => this.onHoverItem(index)}
                  onMouseDown={this.onClickItem(filteredList)}
                  className={filteredList[hoveredItem].id === item.id ? 'active' : ''}
                  ref={(el) => this.arrayItems[item.id] = el}
                >{item.id + ' - ' + item.name}</li>
              ), this)}
            </ul>
          </div>
        )}
      </FormGroup>
    );
  }
}

export default SingleInputWithDropDown;