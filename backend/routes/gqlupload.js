const express = require('express');
const router = express.Router();
const { graphqlUploadExpress } = require('graphql-upload');
const fs = require('fs');
const path = require('path');

async function resolveUpload(upload) {
  const { filename, mimetype, encoding, createReadStream } = upload;
  const stream = createReadStream();
  // Save file to the local filesystem
  const filepath = await saveLocal({ stream, filename });
  // Return metadata to save it to Postgres
  return;
}
 
function saveLocal({ stream, filename }) {
  const filepath = '/files/' + filename;
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

router.post('/',
  graphqlUploadExpress({
    // maxFieldSize: ,
    // maxFileSize: 10000000,
    // maxFiles: 10,
  }),
  async (req, res, next) => {
    if(req.body.operationName === 'MutationWithUpload'){
      console.log(req.body.variables.files)
      const files = req.body.variables.files;
      // console.log(upload);
      Promise.all(files)
        .then(async files => {
          await files.forEach(file => {
            resolveUpload(file);
          });
          next();
        })
        .catch(error => {
          console.log(error)
        })
    } else {
      next();
    }
  }
);

module.exports = router;

