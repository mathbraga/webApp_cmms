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
  GQLs: {
    update: {
      query: gql`
        query MyQuery($id: Int!) {
          formData: allAssetFormData {
            nodes {
              topOptions
              parentOptions
            }
          }
          idData: allFacilityData(condition: {assetId: $id}) {
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
        formData: allAssetFormData {
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
  getInitialFormState: (idData, mode) => {
    
    const baseState = {
      assetSf: "",
      name: "",
      latitude: "",
      longitude: "",
      description: "",
      area: "",
    };

    const result = {
      ...baseState,
      parent: null,
      context: null
    };

    if (mode === 'update') {
      Object.keys(baseState).forEach(key => result[key] = idData ? idData[key] : "");
    }

    result.parents = idData && idData.parents !== null
      ? idData.parents
        .map((parent, index) =>
          (parent &&
          {
            context: idData.contexts[index],
            parent,
            id: `${parent.assetId}-${idData.contexts[index].assetId}`
          }
          ))
      : [];
    return result;
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
