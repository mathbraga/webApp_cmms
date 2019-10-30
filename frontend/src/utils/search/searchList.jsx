const ORDER_CATEGORY_TYPE = {
  'EST': 'Avaliação estrutural',
  'FOR': 'Reparo em forro',
  'INF': 'Infiltração',
  'ELE': 'Instalações elétricas',
  'HID': 'Instalações hidrossanitárias',
  'MAR': 'Marcenaria',
  'PIS': 'Reparo em piso',
  'REV': 'Revestimento',
  'VED': 'Vedação espacial',
  'VID': 'Vidraçaria / Esquadria',
  'SER': 'Serralheria',
  'ARC': 'Ar-condicionado',
  'ELV': 'Elevadores',
  'EXA': 'Exaustores',
  'GRL': 'Serviços Gerais',
};

const ORDER_STATUS_TYPE = {
  'CAN': 'Cancelada',
  'NEG': 'Negada',
  'PEN': 'Pendente',
  'SUS': 'Suspensa',
  'FIL': 'Fila de espera',
  'EXE': 'Execução',
  'CON': 'Concluída',
}

function findItem(items, attributes, term){
  const result = items.filter((item) => {
    for(let i = 0; i < attributes.length; i++){
      let value = [];
      if(attributes[i] === 'subtext' || attributes[i] === 'text')
        value = attributes[i].split('.').reduce(function(p,prop) { return p[prop] }, item);
      else
        value = attributes[i].split('.').reduce(function(p,prop) { return p[prop] }, item.node);

      switch (attributes[i]) {
        case 'orderId':
          value = String(value).padStart(3, "0");
          break;
        case 'category':
          value = ORDER_CATEGORY_TYPE[value];
          break;
        case 'status':
          value = ORDER_STATUS_TYPE[value];
          break;
      }
      if(String(value).toLowerCase().includes(term)){
        return String(value).toLowerCase().includes(term);
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
        let value = [];
        if(attributes[i] === 'subtext' || attributes[i] === 'text')
          value = attributes[i].split('.').reduce(function(p,prop) { return p[prop] }, item);
        else
          value = attributes[i].split('.').reduce(function(p,prop) { return p[prop] }, item.node);
          
        switch (attributes[i]) {
          case 'orderId':
            value = String(value).padStart(3, "0");
            break;
          case 'category':
            value = ORDER_CATEGORY_TYPE[value];
            break;
          case 'status':
            value = ORDER_STATUS_TYPE[value];
            break;
        }
        if(String(value).toLowerCase().includes(searchTermLower[0]))
          return String(value).toLowerCase().includes(searchTermLower[0]);
      }
    })
  }else if(searchTermLower.length > 1){
    searchTermLower.forEach((term) => {
      filteredItems = findItem(filteredItems, attributes, term)});
  }

  return filteredItems;
}