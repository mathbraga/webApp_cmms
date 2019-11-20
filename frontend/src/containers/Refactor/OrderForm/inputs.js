import gql from 'graphql-tag';

export const query = gql`
  query {
    allOrders {
      nodes {
        orderId
        title
        priority
      }
    }
  }
`;

export const config = {
  options: props => ({
    // variables: {},
    fetchPolicy: 'no-cache',
    errorPolicy: 'ignore',
    pollInterval: 0,
    notifyOnNetworkStatusChange: false,
  }),
  // props: ,
  skip: false,
  // name: ,
  // withRef: ,
  // alias: ,
};

export const formInputs = [
  {
    id: 'title',
    name: 'title',
    label: 'Título',
    type: 'text',
    col: '12',
    placeholder: 'Título',
  },
  {
    id: 'description',
    name: 'description',
    label: 'Descrição',
    type: 'textarea',
    col: '12',
    placeholder: 'Descrição',
  },
  {
    id: 'title',
    name: 'title',
    label: 'Título',
    type: 'text',
    col: '12',
    placeholder: 'Título',
  },
  {
    id: 'title',
    name: 'title',
    label: 'Título',
    type: 'text',
    col: '12',
    placeholder: 'Título',
  },
  {
    id: 'title',
    name: 'title',
    label: 'Título',
    type: 'text',
    col: '12',
    placeholder: 'Título',
  },
  {
    id: 'title',
    name: 'title',
    label: 'Título',
    type: 'text',
    col: '12',
    placeholder: 'Título',
  },
  {
    id: 'title',
    name: 'title',
    label: 'Título',
    type: 'text',
    col: '12',
    placeholder: 'Título',
  },
  {
    id: 'title',
    name: 'title',
    label: 'Título',
    type: 'text',
    col: '12',
    placeholder: 'Título',
  },
  {
    id: 'title',
    name: 'title',
    label: 'Título',
    type: 'text',
    col: '12',
    placeholder: 'Título',
  },
];