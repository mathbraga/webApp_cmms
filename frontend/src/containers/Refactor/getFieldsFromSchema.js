import schema from '../../schema.json';
import _ from 'lodash';

export default function getFieldsFromSchema(Type){
  console.clear();
  const types = schema.data.__schema.types
  const i = _.findIndex(types, obj => obj.name === Type);
  const fields = types[i].fields;
  // console.log(fields);
  const formFields = [];
  fields.forEach(field => {
    if(field.args.length === 0 && field.name !== 'nodeId' && field.type.kind !== 'OBJECT'){
      formFields.push(field);
    }
  });
  return formFields;
};