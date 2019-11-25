export default function getIdFromPath(path){
  return Number(path.split('/')[2]);
};