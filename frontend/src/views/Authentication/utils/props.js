import gql from 'graphql-tag';

export default {
  GQLs: {
    all: {
      query: gql`
        query MyQuery {
          queryResponse: authenticate(inputEmail: "matheus.braga@senado.leg.br", inputPassword: "123456")
        }
      `
    }
  }
}
