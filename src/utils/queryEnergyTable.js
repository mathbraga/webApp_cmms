export function queryEnergyTable() {

  // Transform form inputs into integers
  var month1 = this.state.initialDate.slice(5) + this.state.initialDate.slice(0, 2);
  if (this.state.oneMonth) {
    var month2 = month1;
  } else {
    var month2 = this.state.finalDate.slice(5) + this.state.finalDate.slice(0, 2);
  }

  // Define params for query
  const params = {
    TableName: "EnergyTable",
    KeyConditionExpression: 'med = :med AND aamm BETWEEN :aamm1 AND :aamm2',
    ExpressionAttributeValues: {
      ':med': {
        "N": this.state.consumer
      },
      ':aamm1': {
        "N": month1
      },
      ':aamm2': {
        "N": month2
      }
    }
  };

    // Query table and return results
    this.state.dynamo.query(params, (err, data) => {
        if (err) {
            console.log(err);
            console.log("There was an error.")
            this.setState({error: true});
        } else {
            data.Items.map(element => { // Each 'element' is an item returned from the database table; map function loops through all items, changing the variable data
              Object.keys(element).map((key, index) => { // Each key is an attribute of the database table; map function loops through all attributes, changing strings into numbers
                element[key] = Number(element[key].N); // Transforms each element[key].N (string) into Number
              });
            });
            console.log(data);
            this.setState({
              error: false,
              queryResponse: data
            });
        }
    });
}
