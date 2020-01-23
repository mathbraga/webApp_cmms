export default function getSupplyList(options, suppliesList){
  const selectedList = [];
  // console.log(options)
  for(let i = 0; i < options.length; i++){
    if(options[i].selected){
      selectedList.push(suppliesList[i]);
    }
  }
  return selectedList.length === 0 ? null : selectedList;
}