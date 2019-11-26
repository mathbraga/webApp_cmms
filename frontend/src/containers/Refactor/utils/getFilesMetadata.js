const uuidv4 = require('uuid/v4');

export default function getFilesMetadata(files){
  const n = files.length;
  if(n === 0){
    return [];
  } else {
    const filesMetadata = [];
    for(let i = 0; i <= n - 1; i++){
      filesMetadata.push({
        filename: files[i].name,
        uuid: uuidv4(),
        size: files[i].size,
      });
    }
    // console.log(filesMetadata);
    return filesMetadata;
  }
};