// Function used for search mechanics on search dependent components

// import {
//   ORDER_CATEGORY_TYPE, 
//   ORDER_STATUS_TYPE, 
//   ORDER_PRIORITY_TYPE 
// } from "../../views/Maintenance/Tasks/utils/dataDescription";

export default function searchList(itemsList, attributes, searchTerm) {
  let filteredItems = itemsList;
  searchTerm = searchTerm.trim().split(" ");
  const searchTermLower = searchTerm.map((item) => item.toLowerCase());

  searchTermLower.forEach((term) => {
    filteredItems = findItem(filteredItems, attributes, term)
  });

  return filteredItems;
}

function findItem(items, attributes, term) {
  const result = items.filter((item) => {
    for (let i = 0; i < attributes.length; i++) {
      // const relevantName = attributes[i].split('.').pop();
      // const attributeRoot = attributes[i].split('.')[0];
      let value = item[attributes[i]]; // example: item['taskId']

      // if (item.node)
      //   value = attributes[i].split('.').reduce(function (p, prop) { return p[prop] }, item.node);
      // else
      //   value = item[attributes[i]];

      // switch (relevantName) {
      //   case 'orderId':
      //     value = String(value).padStart(4, "0");
      //     break;
      //   case 'category':
      //     value = ORDER_CATEGORY_TYPE[value] || value;
      //     break;
      //   case 'status':
      //     value = ORDER_STATUS_TYPE[value];
      //     break;
      //   case 'priority':
      //     value = ORDER_PRIORITY_TYPE[value];
      //     break;
      // }
      if (String(value).toLowerCase().includes(term)) {
        return String(value).toLowerCase().includes(term);
      }
    }
  })
  return result;
}