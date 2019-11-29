export default function getHrefPath(entityPath, id){
  return '#' + entityPath + '/' + id.toString();
}