const { graphqlUploadExpress } = require('graphql-upload');
const fs = require('fs');
const path = require('path');

async function resolveUpload(upload, uuid) {
  const { filename, mimetype, encoding, createReadStream } = upload;
  const stream = createReadStream();
  // Save file to the local filesystem
  const filepath = await saveLocal({ stream, uuid });
  // Return metadata to save it to Postgres
  return;
}
 
function saveLocal({ stream, uuid }) {
  const filepath = '/files/' + uuid;
  const fsPath = path.join(process.cwd(), filepath);
  return new Promise((resolve, reject) =>
    stream
      .on("error", error => {
        if (stream.truncated)
          // Delete the truncated file
          fs.unlinkSync(fsPath);
        reject(error);
      })
      .on("end", () => resolve(filepath))
      .pipe(fs.createWriteStream(fsPath))
  );
}

async function callback(req, res, next){
  if(req.body.operationName === 'MutationWithUpload' && req.body.variables.files !== null){
    // console.log(req.body.variables.files)
    const files = req.body.variables.files;
    const filesMetadata = req.body.variables.filesMetadata;
    // console.log(upload);
    Promise.all(files.map((file, i) => {
      return file.then(async resolvedFile => {
        return await resolveUpload(resolvedFile, filesMetadata[i].uuid)
      })
    }))
      .then(() => {
        next();
      })
      .catch(error => {
        console.log(error)
      })
  } else {
    next();
  }
}

module.exports = {
  graphqlUpload: graphqlUploadExpress({
  // maxFieldSize: ,
  // maxFileSize: 10000000,
  // maxFiles: 10,
  }),
  callback: callback
};