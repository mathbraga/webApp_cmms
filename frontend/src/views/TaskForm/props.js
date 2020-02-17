import gql from 'graphql-tag';
import validateInput from '../../utils/validateInput';
import paths from '../../paths';

export default {
  paths: paths.task,
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
      taskStatusId: ,
      taskPriorityId: ,
      taskCategoryId: ,
      projectId: ,
      contractId: ,
      teamId: ,
      title: ,
      description: ,
      place: ,
      progress: ,
      dateLimit: ,
      dateStart: ,
      dateEnd: ,
    },
    tops: state.parents.length > 0 ? state.parents.map(parent => parent.context.assetId) : null,
    parents: state.parents.length > 0 ? state.parents.map(parent => parent.parent.assetId) :  null,
  }),
}
