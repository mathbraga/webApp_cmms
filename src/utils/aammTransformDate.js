export default function aammTransformDate(date){
  return date.slice(5) + date.slice(0, 2);
}