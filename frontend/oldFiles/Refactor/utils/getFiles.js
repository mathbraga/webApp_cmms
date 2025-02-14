import uuidv4 from 'uuid/v4';

export default function getFiles(fileList){

  const n = fileList.length;

  const files = n > 0 ? fileList : null;

  let filesMetadata = null;

  if(n > 0){
    filesMetadata = [];
    for(let i = 0; i <= n - 1; i++){
      filesMetadata.push({
        filename: fileList[i].name,
        uuid: uuidv4(),
        size: fileList[i].size,
      });
    }
  }
  return {
    files,
    filesMetadata,
  };
};