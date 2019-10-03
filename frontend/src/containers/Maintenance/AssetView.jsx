import React, { Component } from "react";
import getAsset from "../../utils/assets/getAsset";
import { Button } from "reactstrap";

class AssetView extends Component {
  constructor(props) {
    super(props);
    this.state = {
      asset: false
    }
  }

  componentDidMount() {

    let assetId = this.props.location.pathname.slice(13);

    getAsset(assetId)
      .then(asset => {
        this.setState({
          asset: asset,
        });
      })
      .catch(message => {
        console.log(message);
      });
  }

  render() {
    return (
      <React.Fragment>
        {/* {!this.state.asset ? (
          <h3>Carregando ativo...</h3>
        ) : (
          <React.Fragment>
            <h3>ATIVO: {this.state.asset.id}</h3>
            {this.state.asset.wos.length === 0 ? (
              <p>Não há ordem de serviço no histórico deste ativo.</p>
            ) : (
              <h4>OSs:
                {this.state.asset.wos.map(wo => (
                  <li
                    key={wo}
                  >
                    <Button
                      color="link"
                      onClick={()=>{this.props.history.push("/manutencao/os/view/" + wo.toString())}}
                    >{wo}
                    </Button>
                  </li>
                ))}
              </h4>
            )}
          </React.Fragment>
        )} */}
      </React.Fragment>
    )
  }
}

export default AssetView;
