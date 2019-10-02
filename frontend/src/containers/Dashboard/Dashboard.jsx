import React, { Component } from "react";
import { Container, Row, Col, Card, CardBody, CardHeader, FormGroup, CustomInput, Form, Button } from "reactstrap";

class Dashboard extends Component {
  constructor(props) {
    super(props);
    this.fileInputRef = React.createRef();
    this.state = {
    }
  }

  handleUploadFile = event => {
    event.preventDefault();
    console.clear();
    let photo = this.fileInputRef.current.files[0];
    let formData = new FormData();
    formData.append("photo", photo);
    // console.log(this.fileInputRef.current.files[0]);
    fetch('http://172.30.49.152:3001/upload', {
      method: 'POST',
      body: formData,
    })
      .then(r => r.json())
      .then(rjson => console.log(rjson))
      .catch(()=> console.log('erro upload.'));
  }

  render() {
    return (
      <React.Fragment>
        {/* <div className="flex-row align-items-center">
          <Container>
            <Row className="justify-content-center">
              <Col md="8">
                <Card className="mx-4">
                  <CardBody className="p-4">
                    <h3>
                      Bem-vindo ao webSINFRA
                      {" "}<i className="fa fa-wrench"></i>
                    </h3>
                    <br />
                    <div className="text-muted text-justify">
                      <p>
                        Esta página dá acesso ao sistema de gestão de manutenção da
                        Secretaria de Infraestrutura do Senado Federal - <b>webSINFRA</b>. Para uma melhor
                        experiência, utilize a versão mais atual do navegador Chrome.
                      </p>
                      <p>
                        Para reportar erros, sanar dúvidas ou sugerir melhorias,
                        entre em contato com o SEPLAG no ramal 2339 ou envie um email para ls_seplag@senado.leg.br.
                      </p>
                      {/* <p>Para contribuir ao código-fonte, acesse o{" "}
                        <a
                          href="https://github.com/Serafabr/cmms-web-app"
                          target="_blank"
                          rel="noopener noreferrer nofollow"
                        >repositório no GitHub
                          {" "}<i className="fa fa-github"></i>
                        </a>
                      </p> 
                    </div>
                  </CardBody>
                </Card>
              </Col>
            </Row>
          </Container>
        </div> */}
{/*
        <Card>
          <CardHeader>
            <Row>
              <Col md="12">
                <div className="calc-title">Upload de arquivo</div>
                <div className="calc-subtitle">
                  <em>Utilizar faturas em formato csv</em>
                </div>
              </Col>
            </Row>
          </CardHeader>
          <CardBody>




             <Form
                  enctype="multipart/form-data">
              >
              <Row>
                <Col xs="4">
                  <FormGroup>
                    <CustomInput
                      label="Clique ou arraste para selecionar"
                      type="file"
                      id="csv-file"
                      name="csv-file"
                      innerRef={this.fileInputRef}
                      // onChange={this.handleSelection}
                    />
                  </FormGroup>
                </Col>
                 <Col xs="4">
                  {this.state.isSelected
                    ? <p className="my-2">Arquivo selecionado:
                        <strong>
                        {" " + this.fileInputRef.current.files[0].name}
                      </strong>
                    </p>
                    : <p className="text-muted my-2">Nenhum arquivo selecionado</p>
                  }
                </Col> 
                <Col xs="4">
                  <Button
                    className=""
                    type="submit"
                    size="md"
                    color="primary"
                    onClick={this.handleUploadFile}
                  >Enviar arquivo
                  </Button>
                </Col>
              </Row>
            </Form> 
          </CardBody>
        </Card>
        */}

          <img src="http://localhost:3001/photos/full-moon.jpg" alt="foto"/>

      </React.Fragment>
    );
  }
}

export default Dashboard;
