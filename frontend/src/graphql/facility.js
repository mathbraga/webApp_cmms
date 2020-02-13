import gql from 'graphql-tag';
import validateInput from '../utils/validateInput';

export default {
  name: 'facility',
  idField: 'assetId',
  paths: {
    all: '/edificios',
    one: '/edificios/ver/:id',
    create: '/edificios/criar',
    update: '/edificios/editar/:id',
  },
  baseState: {
    assetSf: "",
    name: "",
    latitude: "",
    longitude: "",
    description: "",
    area: "",
  },
  addNewCustomStates: (itemData, currentState) => {
    const result = { ...currentState, parent: null, context: null };
    result.parents = itemData && itemData.parents !== null
      ? itemData.parents
        .map((parent, index) =>
          (parent &&
          {
            context: itemData.contexts[index],
            parent,
            id: `${parent.assetId}-${itemData.contexts[index].assetId}`
          }
          ))
        // .filter(item => (item !== null))
      : [];
    return result;
  },
  GQLs: {
    update: {
      query: gql`
        query MyQuery($id: Int!) {
          allAssetFormData {
            nodes {
              topOptions
              parentOptions
            }
          }
          itemData: allFacilityData(condition: {assetId: $id}) {
            nodes {
              assetId
              assetSf
              area
              categoryName
              description
              latitude
              longitude
              name
              tasks
              contexts
              parents
            }
          }
        }
      `,
      mutation: gql`
        mutation (
          $id: Int!,
          $attributes: AssetInput!,
          $tops: [Int!]!,
          $parents: [Int!]!
        ) {
          mutationResponse:  modifyAsset (
            input: {
              id: $id
              attributes: $attributes
              tops: $tops
              parents: $parents
            }
          ) {
            result
          }
        }
      `
    },
    create: {
      query: gql`
      query MyQuery {
        allAssetFormData {
          nodes {
            topOptions
            parentOptions
          }
        }
      }
    `,
      mutation: gql`
        mutation (
          $attributes: AssetInput!,
          $tops: [Int!]!,
          $parents: [Int!]!
        ) {
          mutationResponse:  insertAsset (
            input: {
              attributes: $attributes
              tops: $tops
              parents: $parents
            }
          ) {
            result
          }
        }
      `
    }
  },
  getFormVariables: state => ({
    attributes: {
      assetSf: validateInput(state.assetSf),
      name: validateInput(state.name),
      description: validateInput(state.description),
      category: 1,
      latitude: validateInput(state.latitude),
      longitude: validateInput(state.longitude),
    },
    tops: state.parents.length > 0 ? state.parents.map(parent => parent.context.assetId) : null,
    parents: state.parents.length > 0 ? state.parents.map(parent => parent.parent.assetId) :  null,
  }),
}
