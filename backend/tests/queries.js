const queries = {
  INSERT_TASK_QUERY: 'select * from insert_task($1, $2, $3, $4, $5)',
  INSERT_ASSET_QUERY: 'select * from insert_asset($1)',
  INSERT_PERSON_QUERY: 'select * from insert_person($1, $2)',
};

module.exports = queries;
