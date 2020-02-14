import gql from 'graphql-tag';

export default {
  GQLs: {
    create: {
      query: gql`
        query MyQuery {
          allTaskFormData {
            nodes {
              assetOptions
              categoryOptions
              contractOptions
              priorityOptions
              projectOptions
              statusOptions
              teamOptions
            }
          }
        }
      `
    }
  }
}
