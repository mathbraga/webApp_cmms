import React, { Component } from "react";
import { Container, Row, Col, Card, CardBody, CardHeader, FormGroup, CustomInput, Form, Button } from "reactstrap";
const uuidv4 = require('uuid/v4');

class Dashboard extends Component {
  constructor(props) {
    super(props);
    this.fileInputRef = React.createRef();
    this.state = {
    }
  }

  // componentWillMount = () => {
  //   console.clear();
  //   fetch('http://redminesf.senado.gov.br/redmine/issues/75351.json', {
  //     method: 'GET',
  //     // mode: 'no-cors',
  //     credentials: "include",
  //   })
  //   .then(r => console.log(r))
  //   .catch(r => console.log(r))
  // }


  handleUploadFile = event => {
    event.preventDefault();
    console.clear();
    let files = this.fileInputRef.current.files;
    let l = files.length;
    console.log(files);
    let formData = new FormData();
    for (let i = 0; i < l; i++) { // forEach() and map() are not defined for an array of files
      let field = ''
      if(i === 0) {
        field = 'image';
      } else {
        field = 'files';
      }
      formData.append(
        field,
        files[i],
        uuidv4() + '.' + files[i].type.split('/')[1]
      );
    }
    // console.log(formData.get('image'))
    fetch('http://172.30.49.152:3001/db', {
      method: 'POST',
      body: formData,
    })
      .then(r => r.json())
      .then(rjson => console.log(rjson))
      .catch(() => console.log('erro upload.'));
  }

  render() {
    return (
      <React.Fragment>
        <div className="flex-row align-items-center">
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
                      </p> */}
                    </div>
                  </CardBody>
                </Card>
              </Col>
            </Row>
          </Container>
        </div>

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
            <Form>
              <Row>
                <Col xs="4">
                  <FormGroup>
                    <CustomInput
                      multiple={true}
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

        <div>
          <img
            src="http://localhost:3001/images/newfilename-1.jpeg"
            alt="foto"
            height="140"
            width="190"
          />
        </div>

        <div>
          <a
            download
            href="http://localhost:3001/files/touch.txt"
            target="_blank"
            rel="noopener noreferrer nofollow"
          >Aqui o link
          </a>
        </div>
      </React.Fragment>
    );
  }
}

export default Dashboard;
