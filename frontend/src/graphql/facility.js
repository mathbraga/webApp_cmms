import gql from 'graphql-tag';

export default {
  name: 'facility',
  idField: 'assetId',
  paths: {
    all: '/edificios',
    one: '/edificios/visualizar/:id',
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
    result.parents = itemData
      ? itemData.parents
        .map((parent, index) =>
          (parent &&
          {
            context: itemData.contexts[index],
            parent,
            id: `${parent.assetId}-${itemData.contexts[index].assetId}`
          }
          ))
        .filter(item => (item !== null))
      : [];
    return result;
  },
  GQLs: {
    update: {
      query: gql`
        query MyQuery($assetId: Int!) {
          allAssetFormData {
            nodes {
              topOptions
              parentOptions
            }
          }
          entityData: allFacilityData(condition: {assetId: $assetId}) {
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
          $attributes: AssetInput!,
          $tops: [Int!]!,
          $parents: [Int!]!
        ) {
          mutationResponse:  modifyAsset (
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
}
