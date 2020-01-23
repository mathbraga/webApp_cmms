export default function getDownloadPath(uuid){
  return (
    process.env.REACT_APP_SERVER_URL +
    process.env.REACT_APP_DOWNLOAD_PATH +
    '/' +
    uuid
  )
};