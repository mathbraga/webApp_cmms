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

const ORDER_PRIORITY_TYPE = {
  'BAI': 'Baixa',
  'NOR': 'Normal',
  'ALT': 'Alta',
  'URG': 'Urgente',
};

function findItem(items, attributes, term){
  const result = items.filter((item) => {
    for(let i = 0; i < attributes.length; i++){
      const relevantName = attributes[i].split('.').pop();
      //const attributeRoot = attributes[i].split('.')[0];
      let value = [];
      if(item.node)
        value = attributes[i].split('.').reduce(function(p,prop) { return p[prop] }, item.node);
      else
        value = attributes[i].split('.').reduce(function(p,prop) { return p[prop] }, item);

      switch (relevantName) {
        case 'orderId':
          value = String(value).padStart(4, "0");
          break;
        case 'category':
          value = ORDER_CATEGORY_TYPE[value] || value;
          break;
        case 'status':
          value = ORDER_STATUS_TYPE[value];
          break;
        case 'priority':
          value = ORDER_PRIORITY_TYPE[value];
          break;
      }
      if(String(value).toLowerCase().includes(term)){
        return String(value).toLowerCase().includes(term);
      }
    }
  })
  return result;
}

export default function searchList(itemsList, attributes, searchTerm){  
  let filteredItems = itemsList;
  searchTerm = searchTerm.trim().split(" ");
  const searchTermLower = searchTerm.map((item) => item.toLowerCase());

  searchTermLower.forEach((term) => {
    filteredItems = findItem(filteredItems, attributes, term)
  });

  return filteredItems;
}