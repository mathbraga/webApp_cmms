import React, { Component } from "react";
import {
  Badge,
  Table,
  Card,
  CardBody,
  Input,
} from 'reactstrap';

class MultipleSelect extends Component {
  constructor(props) {
    super(props);
  }

  render() {

    const { config, selected, addItem, removeItem, handleQty } = this.props;
    let idx = -1;

    return (
      <Card>
        <CardBody>
          <p><strong>{config.label}</strong></p>
          <Table hover borderless size='sm' style={{display: 'block', height: '10rem', overflow: 'scroll'}}>
            <tbody>
              {config.options.map((option, i) => (
                <tr key={i}>
                  <td>
                    <Badge
                      size='sm'
                      name={option.id}
                      href={"#"}
                      color='success'
                      onClick={addItem}
                    >+</Badge>
                    &nbsp;&nbsp;
                    {option.sf + ' - ' + option.name}
                  </td>
                </tr>
              ))}
            </tbody>
          </Table>
          <hr/>

          {selected.length === 0 ? (
            <p style={{textAlign: 'right'}}><em>Nenhum item selecionado</em></p>
          ) : (
            <React.Fragment>
              <p style={{textAlign: 'right'}}><em>Defina as quantidades</em></p>
              <Table hover borderless size='sm'>
                <tbody>
                  {selected.map((selectedId, i) => {
                    const selectedItem = config.options.find(option => selectedId === option.id)
                      idx++;
                      return (
                        <tr key={selectedItem.id}>
                      <td>
                        <Badge
                          name={selectedItem.id}
                          href={"#"}
                          color='danger'
                          onClick={removeItem}
                        >X
                        </Badge>
                        &nbsp;&nbsp;
                        {selectedItem.sf + ' - ' + selectedItem.name}
                      </td>
                      <td style={{width: '5rem'}}>
                      <Input
                        style={{textAlign: 'right'}}
                        type='text'
                        name={idx}
                        bsSize='sm'
                        placeholder={selectedItem.placeholder}
                        onBlur={handleQty}
                      ></Input>
                      </td>
                    </tr>
                      )
                  })}
                </tbody>
              </Table>
            </React.Fragment>
          )}
        </CardBody>
      </Card>
    );
  }
}

export default MultipleSelect;
