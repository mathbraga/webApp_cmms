export default function getMeterTypeText(tipoAttr){
  
  const typeTextOptions = {
    "0": "Convencional",
    "1": "Horária - Verde",
    "2": "Horária - Azul"
  };

  console.log(typeTextOptions[tipoAttr.toString()]);

  return typeTextOptions[tipoAttr.toString()];

}