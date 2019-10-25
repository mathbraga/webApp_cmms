function findItem(items, attributes, term){
  const result = items.filter((item) => {
    for(let i = 0; i < attributes.length; i++){
      if(String(item.node[attributes[i]]).toLowerCase().includes(term)){
        return String(item.node[attributes[i]]).toLowerCase().includes(term);
      }
    }
  })
  console.log(result);
  return result;
}

export default function searchList(itemsList, attributes, searchTerm){  
  let filteredItems = itemsList;
  searchTerm = searchTerm.trim().split(" ");
  const searchTermLower = searchTerm.map((item) => item.toLowerCase());

  if(searchTermLower.length === 1){
    filteredItems = itemsList.filter((item) => {
      for(let i = 0; i < attributes.length; i++){
        if(String(item.node[attributes[i]]).toLowerCase().includes(searchTermLower[0])){
          return String(item.node[attributes[i]]).toLowerCase().includes(searchTermLower[0]);
        }
      }
    })
  }else if(searchTermLower.length > 1){
    searchTermLower.forEach((term) => {
      filteredItems = findItem(filteredItems, attributes, term)});
  }

  return filteredItems;
}