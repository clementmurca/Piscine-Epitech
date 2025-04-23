export const formatDate = (dateInput) => {
  let date;
  if (typeof dateInput === 'object' && dateInput.year && dateInput.month && dateInput.day) {
    const { year, month, day, hour = 0, minute = 0, second = 0 } = dateInput;
    date = new Date(Date.UTC(
      year,
      month - 1, 
      day,
      hour,
      minute,
      second
    ));
  } else {
    date = new Date(dateInput);
  }
  const year = date.getUTCFullYear();
  const month = String(date.getUTCMonth() + 1).padStart(2, '0');
  const day = String(date.getUTCDate()).padStart(2, '0');
  const hours = String(date.getUTCHours()).padStart(2, '0');
  const minutes = String(date.getUTCMinutes()).padStart(2, '0');
  const seconds = String(date.getUTCSeconds()).padStart(2, '0');

  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
};
