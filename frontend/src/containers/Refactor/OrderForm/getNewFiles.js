import { uuidv4 } from 'uuid/v4';

export default function getNewFiles(files){
  
  const resultObj = {
    files: [],
    filesMetadata: [],
  };
  
  if(files.length === 0){
    return resultObj;
  } else {
    for(let i = 0; i < files.length; i++){
      const uuid = uuidv4().replace('-', '') + '.' + files[i].name.split('.')[1];
      resultObj.files.push((new File(
        [files[i]],
        uuid,
        {
          type: files[i].type,
          lastModified: files[i].lastModified
        }
      )));
      resultObj.filesMetadata.push({
        filename: files[i].name,
        uuid: uuid,
        size: files[i].size,
      });
    }
    return resultObj;
  }
};