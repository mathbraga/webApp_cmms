
// TODO: Testing file upload with curl

const curl = `curl localhost:3001/graphql \
-F operations='{ "query": "mutation($files: [Upload!]!) { multipleUpload(files: $files) { id } }", "variables": { "files": [null, null] } }' \
-F map='{ "0": ["variables.files.0"], "1": ["variables.files.1"] }' \
-F 0=@b.txt \
-F 1=@c.txt`