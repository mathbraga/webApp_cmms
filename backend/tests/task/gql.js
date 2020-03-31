module.exports = 
`{ \
  "variables": { \
    "id":null, \
    "attributes": { \
      "taskStatusId":1, \
      "taskPriorityId":1, \
      "taskCategoryId":1, \
      "projectId":null, \
      "contractId":null, \
      "teamId":null, \
      "title":"title", \
      "description":"description", \
      "place":null, \
      "progress":null, \
      "dateLimit":null, \
      "dateStart":null, \
      "dateEnd":null \
    }, \
    "assets":[1], \
    "files":[null], \
    "filesMetadata":[{ \
      "filename":"test.txt", \
      "uuid":"de741848-5e90-4c5e-8699-78aca9b37aba", \
      "size":1234 \
    }] \
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
}`;
