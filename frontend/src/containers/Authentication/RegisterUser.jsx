import React, { Component } from "react";
import signup from "../../utils/authentication/signup";
import loginFetch from "../../utils/authentication/loginFetch";
import { Alert, Button, Card, CardBody, Col, Container, Form, Input, InputGroup, InputGroupAddon, InputGroupText, Row } from 'reactstrap';
import { Query, Mutation } from 'react-apollo';
import gql from 'graphql-tag';

class RegisterUser extends Component {
  constructor(props){
    super(props);
    this.state = {
      email: "",
      name: "",
      surname: "",
      phone: "",
      department: "",
      contract: "",
      category: "E",
      password1: "",
      password2: "",
      isFetching: false,
      signupError: false,
      alertVisible: false,
      alertMessage: "",
    }
  }

  componentWillMount = () => {
    if(this.props.email || window.localStorage.getItem('session') !== null){
      this.props.history.push("/painel");
    }
  }

  handleInputs = event => {
    event.persist();
    if(event.target.name === 'category'){
      switch(event.target.value){
        case 'E':
          this.setState({
            category: 'E',
            contract: null,
          });
          break;
        case 'T':
          this.setState({
            category: 'T',
            department: null,
          });
          break;
      }
    } else {
      this.setState({
        [event.target.name]: event.target.value
      });
    }
  }

  closeAlert = () => {
    this.setState({
      alertVisible: false
    });
  }

  render() {

    const formOptions = gql`
      {
        __type(name: "PersonCategoryType") {
          name
          enumValues {
            name
          }
        }
        allDepartments {
          nodes {
            departmentId
            fullName
          }
        }
      }
    `;
    
    const newUser = gql`
      mutation MyMutation(
        $email: String!
        $name: String!
        $surname: String!
        $phone: String!
        $department: String!
        $contract: String!
        $category: String!
        $password: String!
        ){
        registerUser(input: {
            inputEmail: $email,
            inputName: $name,
            inputSurname: $surname,
            inputPhone: $phone,
            inputDepartment: $department,
            inputContract: $contract,
            inputCategory: $category,
            inputPassword: $password
        }) {
          person {
            email
          }
        }
      }
    `;
    
    const mutate = (newData) => {
      newData().then((data) => console.log(data))
    }

    return (
      <Mutation
        mutation={newUser}
        variables={{
          email: this.state.email,
          name: this.state.name,
          surname: this.state.surname,
          phone: this.state.phone,
          department: this.state.department,
          contract: this.state.contract,
          category: this.state.category,
          password: this.state.password1
        }}
      >{(mutation, {data, loading, error}) => {
        if (loading) return null;
        if(error){
          console.log(error);
          // this.handleError();
        }
        return(
          <Query query={formOptions}>{({data, loading, error}) => {
            if(loading) return null
            if(error){
              console.log(error);
              return null
            }

            const categoriesArr = data.__type.enumValues;

            const departmentsArr = data.allDepartments.nodes;

            // console.log('form options:\n');
            // console.log('categories:');
            // console.log(categoriesArr);
            // console.log('contracts:');
            // console.log(contractsArr);
            // console.log('departments:');
            // console.log(departmentsArr);

            return(
              <div className="flex-row align-items-center">
                <Container>
                  <Row className="justify-content-center">
                    <Col md="6">
                      <Card className="mx-4">
                        <CardBody className="p-4">
                          <Form
                            onSubmit={event => {
                              event.preventDefault();
                              if(this.state.password1 === this.state.password2){
                                mutate(mutation);
                              } else {
                                console.log('hehehe');
                              }
                            }}
                          >
                            <h1>Cadastro</h1>
                            <p className="text-muted">Crie sua conta para acessar o CMMS da SINFRA.</p>
                            
                            <InputGroup className="mb-3">
                              <InputGroupAddon addonType="prepend">
                                <InputGroupText>
                                  <i className="icon-user"></i>
                                </InputGroupText>
                              </InputGroupAddon>
                              <Input
                                type="text"
                                id="fullName"
                                name="fullName"
                                placeholder="Nome completo"
                                onChange={this.handleInputs}
                                disabled={this.state.isFetching}
                                autoFocus
                              />
                            </InputGroup>
                            
                            <InputGroup className="mb-3">
                              <InputGroupAddon addonType="prepend">
                                <InputGroupText>
                                  <i className="icon-user"></i>
                                </InputGroupText>
                              </InputGroupAddon>
                              <Input
                                type="text"
                                id="cpf"
                                name="cpf"
                                placeholder="CPF (somente números)"
                                onChange={this.handleInputs}
                                innerRef={this.emailInputRef}
                                disabled={this.state.isFetching}
                              />
                            </InputGroup>
                            
                            <InputGroup className="mb-3">
                              <InputGroupAddon addonType="prepend">
                                <InputGroupText>
                                  <i className="icon-user"></i>
                                </InputGroupText>
                              </InputGroupAddon>
                              <Input
                                type="text"
                                id="email"
                                name="email"
                                placeholder="Email"
                                onChange={this.handleInputs}
                                disabled={this.state.isFetching}
                              />
                            </InputGroup>

                            <InputGroup className="mb-3">
                              <InputGroupAddon addonType="prepend">
                                <InputGroupText>
                                  <i className="icon-phone"></i>
                                </InputGroupText>
                              </InputGroupAddon>
                              <Input
                                type="text"
                                id="phone"
                                name="phone"
                                placeholder="Telefone"
                                onChange={this.handleInputs}
                                disabled={this.state.isFetching}
                              />
                            </InputGroup>

                            <InputGroup className="mb-3">
                              <InputGroupAddon addonType="prepend">
                                <InputGroupText>
                                  <i className="icon-screen-smartphone"></i>
                                </InputGroupText>
                              </InputGroupAddon>
                              <Input
                                type="text"
                                id="cellphone"
                                name="cellphone"
                                placeholder="Celular"
                                onChange={this.handleInputs}
                                disabled={this.state.isFetching}
                              />
                            </InputGroup>

                            <InputGroup className="mb-3">
                              <InputGroupAddon addonType="prepend">
                                <InputGroupText>
                                  <i className="icon-briefcase"></i>
                                </InputGroupText>
                              </InputGroupAddon>
                              <Input
                                type="select"
                                id="personRole"
                                name="personRole"
                                onChange={this.handleInputs}
                                disabled={this.state.isFetching}
                              >
                                {/* <option >Nível de acesso ao CMMS</option> */}
                                <optgroup disabled selected label='Nível de acesso ao CMMS'>
                                  <option value={'employee'} >Colaborador da SINFRA</option>
                                  <option value={'employee'} >Funcionário de contrato de manutenção</option>
                                </optgroup>
                              ))}
                              </Input>
                            </InputGroup>

                            <InputGroup className="mb-3">
                              <InputGroupAddon addonType="prepend">
                                <InputGroupText>
                                  <i className="icon-briefcase"></i>
                                </InputGroupText>
                              </InputGroupAddon>
                              <Input
                                type="select"
                                id="department"
                                name="department"
                                placeholder="Departamento"
                                onChange={this.handleInputs}
                                disabled={this.state.category === 'T'}
                                value={this.state.department}
                              >
                                <option
                                  value={''}
                                >
                                  Selecione o departamento
                                </option>
                                {departmentsArr.map(dept => (
                                <option
                                  key={dept.departmentId}
                                  value={dept.department}
                                >
                                  {dept.departmentId}
                                </option>
                              ))}
                              </Input>
                            </InputGroup>

                            {/* <InputGroup className="mb-3">
                              <InputGroupAddon addonType="prepend">
                                <InputGroupText>
                                  <i className="icon-briefcase"></i>
                                </InputGroupText>
                              </InputGroupAddon>
                              <Input
                                type="select"
                                id="contract"
                                name="contract"
                                placeholder="Contrato"
                                onChange={this.handleInputs}
                                disabled={this.state.category === 'E'}
                                value={this.state.contract}
                              >
                                <option
                                  value={''}
                                >
                                  Selecione o contrato
                                </option>
                                {contractsArr.map(contract => (
                                <option
                                  key={contract.contractId}
                                  value={contract.contractId}
                                  >
                                  {contract.contractId}
                                </option>
                              ))}
                              </Input>
                            </InputGroup> */}

                            <InputGroup className="mb-3">
                              <InputGroupAddon addonType="prepend">
                                <InputGroupText>
                                  <i className="icon-lock"></i>
                                </InputGroupText>
                              </InputGroupAddon>
                              <Input
                                type="password"
                                placeholder="Senha"
                                id="password1"
                                name="password1"
                                onChange={this.handleInputs}
                                disabled={this.state.isFetching}
                              />
                            </InputGroup>

                            <InputGroup className="mb-4">
                              <InputGroupAddon addonType="prepend">
                                <InputGroupText>
                                  <i className="icon-lock"></i>
                                </InputGroupText>
                              </InputGroupAddon>
                              <Input
                                type="password"
                                placeholder="Repita sua senha"
                                id="password2"
                                name="password2"
                                onChange={this.handleInputs}
                                disabled={this.state.isFetching}
                              />
                            </InputGroup>

                            <Button
                              color="primary"
                              type="submit"
                              block
                              // onClick={this.handleSubmit}
                              disabled={this.state.isFetching}
                              >Cadastrar
                            </Button>

                          </Form>
                        </CardBody>
                      </Card>

                      <Alert
                        className="mt-4 mx-4"
                        color={this.state.signupError ? "danger" : "warning"}
                        isOpen={this.state.alertVisible}
                        toggle={this.closeAlert}
                      >{this.state.alertMessage}
                      </Alert>
                      
                    </Col>
                  </Row>
                </Container>
              </div>
            )
          }}</Query>
        );
      }}</Mutation>
    );
  }
}

export default RegisterUser;
