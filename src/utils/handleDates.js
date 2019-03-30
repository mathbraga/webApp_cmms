export function handleDates(event) {
  const { name, value } = event.target;
  const justNumbers = value.replace(/\D/g, "");

  if (value.length > 7) {
    return;
  }

  if (value.length === 3 && value[2] === "/") {
    this.setState({
      [name]: value
    });
    return;
  }

  if (justNumbers.length <= 2) {
    this.setState({
      [name]: justNumbers
    });
  } else {
    const newDate =
      justNumbers.slice(0, 2) + "/" + justNumbers.slice(2, justNumbers.length);
    this.setState({
      [name]: newDate
    });
  }
}
