// Function used for search mechanics on search dependent components
export default function searchList(itemsList, attributes, searchTerm) {
  let filteredItems = itemsList;
  searchTerm = searchTerm.trim().split(" ");
  const searchTermLowerCase = searchTerm.map((item) => item.toLowerCase());

  searchTermLowerCase.forEach((term) => {
    filteredItems = findItem(filteredItems, attributes, term)
  });

  return filteredItems;
}

function findItem(items, attributes, term) {
  const result = items.filter((item) => {
    for (let i = 0; i < attributes.length; i++) {
      let value = [];
      if (item.node)
        value = attributes[i].split('.').reduce(function (p, prop) { return p[prop] }, item.node);
      else
        value = attributes[i].split('.').reduce(function (p, prop) { return p[prop] }, item);
      if (String(value).toLowerCase().includes(term)) {
        return String(value).toLowerCase().includes(term);
      }
    }
  })
  return result;
}