function buildReqBody(vars){
return `{ \
  "variables": { \
    "id":${vars.id}, \
    "attributes": { \
      "taskStatusId":${vars.taskStatusId}, \
      "taskPriorityId":${vars.taskPriorityId}, \
      "taskCategoryId":${vars.taskCategoryId}, \
      "projectId":${vars.projectId}, \
      "contractId":${vars.contractId}, \
      "teamId":${vars.teamId}, \
      "title":${vars.title}, \
      "description":${vars.description}, \
      "place":${vars.place}, \
      "progress":${vars.progress}, \
      "dateLimit":${vars.dateLimit}, \
      "dateStart":${vars.dateStart}, \
      "dateEnd":${vars.dateEnd} \
    }, \
    "assets":${vars.assets}, \
    "files":${vars.files}, \
    "filesMetadata":${vars.filesMetadata}
  }, \
  "query":"mutation ( \
    $attributes: TaskInput!, \
    $assets: [Int!]!, \
    $filesMetadata: [FileMetadatumInput] \
  ) { \
    insertTask(input:{ \
      attributes: $attributes, \
      assets: $assets, \
      filesMetadata: $filesMetadata \
    }) { \
      id \
      __typename \
    } \
  }" \
}`
}

const vars = {
  id:'null',
  taskStatusId:'1',
  taskPriorityId:'1',
  taskCategoryId:'1',
  projectId:'null',
  contractId:'null',
  teamId:'null',
  title:'"title"',
  description:'"description"',
  place:'null',
  progress:'null',
  dateLimit:'null',
  dateStart:'null',
  dateEnd:'null',
  assets:'[1]',
  // files:'[null]',
  // filesMetadata:'[{"filename":"test.txt","uuid":"de741848-5e90-4c5e-8699-78aca9b37aba","size":1234}]'
  files: 'null',
  filesMetadata: 'null',
}



module.exports = {gql:  buildReqBody(Object.assign(
  {},
  {...vars},
  {
    files: '[null]',
    filesMetadata: '[{"filename":"test.txt","uuid":"de741848-5e90-4c5e-8699-78aca9b37aba","size":1234}]'
  }
))}
