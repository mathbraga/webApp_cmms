import React, { Component } from "react";
import { Alert, Button, Card, CardBody, Col, Container, Form, Input, InputGroup, InputGroupAddon, InputGroupText, Row } from 'reactstrap';
import { login } from "../../redux/actions";
import { connect } from "react-redux";
import ModalForgottenPassword from "../../components/Modals/ModalForgottenPassword";
import { serverAddress } from "../../constants";

class Login extends Component {
  constructor(props){
    super(props);
    this.passwordInputRef = React.createRef();
    this.state = {
      email: "",
      password: "",
      alertVisible: false,
      modalVisible: false
    }
  }

  componentWillMount = () => {
    // fetch('http://172.30.49.152:3001/login', {
    //   method: 'POST',
    //   credentials: 'include',
    //   body: JSON.stringify({
    //     username: 'hehehehehehe@senado.leg.br',
    //     password: '123456'
    //   }),
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'Accept': 'application/json',
    //   },
    // })

    //   .then(r => r.json())
    //   .then(rjson => console.log(rjson))
    //   .catch(()=>console.log('Erro no fecth em Dashboard'));


  }

  componentDidUpdate = prevProps => {
    if(this.props.loginError !== prevProps.loginError){
      if(this.props.loginError){
        this.setState({
          alertVisible: true,
          password: ""
        });
        this.passwordInputRef.current.value = "";
      }
    }
  }

  handleLoginInputs = event => {
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  handleLoginSubmit = event => {
    event.preventDefault();
    // this.props.dispatch(login(this.state.email, this.state.password, this.props.history));

    this.setState({
      alertVisible: true,
      alertMessage: "Realizando login...",
      loginError: false,
    });

    fetch('http://172.30.49.152:3001/login', {
      method: 'POST',
      credentials: 'include',
      body: JSON.stringify({
        email: this.state.email,
        password: this.state.password
      }),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    })
      .then(r => r.json())
      .then(rjson => {
        console.log(rjson);
        this.props.history.push('/painel');
      })
      .catch(() => {
        console.log('Erro no fetch de login');
      });
  }

  closeAlert = event => {
    this.setState({
      alertVisible: false
    });
  }

  openModal = () => {
    this.setState({
      modalVisible: true
    });
  }

  closeModal = () => {
    this.setState({
      modalVisible: false
    });
  }

  render() {
    return (
      <React.Fragment>
        <div className="flex-row align-items-center">
          <Container>
            <Row className="justify-content-center">
              <Col md="6">
                <Card className="mx-4">
                  <CardBody className="p-4">
                    <Form>
                      <h1>Login</h1>
                      <p className="text-muted">Faça login em sua conta.</p>
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
                          value={this.state.email}
                          placeholder="usuario@senado.leg.br"
                          autoComplete="username"
                          onChange={this.handleLoginInputs}
                          autoFocus
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
                          id="password"
                          name="password"
                          value={this.state.password}
                          placeholder="Senha"
                          autoComplete="current-password"
                          onChange={this.handleLoginInputs}
                          innerRef={this.passwordInputRef}
                        />
                      </InputGroup>
                      <Row>
                        <Col xs="6">
                          <Button
                            block
                            color="primary"
                            className="px-4"
                            onClick={this.handleLoginSubmit}  
                          >Login</Button>
                        </Col>
                        <Col xs="6" className="text-right">
                          <Button
                            block
                            outline
                            color="primary"
                            className="px-0"
                            onClick={this.openModal}
                          >Esqueceu sua senha?
                          </Button>
                        </Col>
                      </Row>
                    </Form>
                  </CardBody>
                </Card>

                <Alert className="mt-4 mx-4" color="warning" isOpen={this.props.isFetching}>
                  Realizando login...
                </Alert>

                {!this.props.isFetching &&
                  <Alert className="mt-4 mx-4" color="danger" isOpen={this.state.alertVisible} toggle={this.closeAlert}>
                    Login falhou. Tente novamente.
                  </Alert>
                }

              </Col>
            </Row>
          </Container>
        </div>

        <ModalForgottenPassword
          isOpen={this.state.modalVisible}
          toggle={this.closeModal}
        />

      </React.Fragment>
    );
  }
}

const mapStateToProps = storeState => {
  let isFetching = storeState.auth.isFetching;
  let loginError = storeState.auth.loginError;
  let session = storeState.auth.session;
  return {
    isFetching: isFetching,
    loginError: loginError,
    session: session
  };
}

export default connect(mapStateToProps)(Login);