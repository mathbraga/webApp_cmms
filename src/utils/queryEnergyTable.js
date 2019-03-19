export function queryEnergyTable() {
  // Transform form inputs into integers
  var month1 =
    this.state.initialDate.slice(5) + this.state.initialDate.slice(0, 2);
  if (this.state.oneMonth) {
    var month2 = month1;
  } else {
    var month2 =
      this.state.finalDate.slice(5) + this.state.finalDate.slice(0, 2);
  }

  // Query EnergyTable and return results
  this.state.dynamo.query({
    TableName: "EnergyTable",
    KeyConditionExpression: "med = :med AND aamm BETWEEN :aamm1 AND :aamm2",
    ExpressionAttributeValues: {
      ":med": {
        N: this.state.consumer
      },
      ":aamm1": {
        N: month1
      },
      ":aamm2": {
        N: month2
      }
    }
  }, (err, data) => {
    if (err) {
      console.log(err);
      alert("There was an error. Please insert search parameters again.");
      this.setState({ error: true });
    } else {
      data.Items.map(element => {
        // Each 'element' is an item returned from the database table; map function loops through all items, changing the variable data
        Object.keys(element).map(key => {
          // Each key is an attribute of the database table; map function loops through all attributes, changing strings into numbers
          element[key] = Number(element[key].N); // Transforms each element[key].N (string) into Number
        });
      });
      console.log(data);
      this.setState({
        // error: false,
        queryResponse1: data,
        showResult1: true
      });
    }
  });

  // Query EnergyInfo and return results
  this.state.dynamo.query({
    TableName: "EnergyInfo",
    KeyConditionExpression: "med = :med",
    ExpressionAttributeValues: {
      ":med": {
        N: this.state.consumer
      }
    }
  }, (err, data) => {
    if (err) {
      console.log(err);
      alert("There was an error. Please insert search parameters again.");
      this.setState({ error: true });
    } else {
      console.log(data);
      this.setState({
        error: false,
        queryResponse2: data,
        showResult2: true
      });
    }
  });
}
