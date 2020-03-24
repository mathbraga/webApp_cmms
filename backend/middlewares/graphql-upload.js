const { graphqlUploadExpress } = require('graphql-upload');
const fs = require('fs');
const path = require('path');
const paths = require('../paths');

async function resolveUpload(upload, uuid) {
  const { filename, mimetype, encoding, createReadStream } = upload;
  const stream = createReadStream();
  // Save file to the local filesystem
  const filepath = await saveLocal({ stream, uuid });
  // Return metadata to save it to Postgres
  return;
}
 
function saveLocal({ stream, uuid }) {
  const fsPath = path.join(process.cwd(), paths.files, uuid);
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

function reqHasFiles(req){
  return req.body.variables && req.body.variables.files;
}

async function callback(req, res, next){
  if(reqHasFiles(req)){
    const files = req.body.variables.files;
    const filesMetadata = req.body.variables.filesMetadata;
    Promise.all(files.map((file, i) => {
      return file.then(async resolvedFile => {
        return await resolveUpload(resolvedFile, filesMetadata[i].uuid)
      })
    }))
      .then(() => {
        next();
      })
      .catch(error => {
        console.log(error);
        res.status(500).end();
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