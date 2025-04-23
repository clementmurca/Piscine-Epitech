export function formatDate(dateInput) {
    if (!dateInput) {
      console.error("Received empty or null date:", dateInput);
      return '';
    }
  
    try {
      let date;
  
      // Handle Elixir-style date object
      if (typeof dateInput === 'object' && !Array.isArray(dateInput) && !(dateInput instanceof Date)) {
        if (dateInput.year !== undefined && dateInput.month !== undefined && dateInput.day !== undefined) {
          const year = dateInput.year;
          const month = dateInput.month; // Don't subtract 1 here since Elixir months are 1-indexed
          const day = dateInput.day;
          const hour = dateInput.hour || 0;
          const minute = dateInput.minute || 0;
          const second = dateInput.second || 0;
  
          date = new Date(Date.UTC(year, month - 1, day, hour, minute, second));
        } else {
          throw new Error("Invalid Elixir date object structure");
        }
      }
      // Handle Date object
      else if (dateInput instanceof Date) {
        date = dateInput;
      }
      // Handle ISO string or timestamp
      else if (typeof dateInput === 'string') {
        date = new Date(dateInput);
      }
      // Handle timestamp number
      else if (typeof dateInput === 'number') {
        date = new Date(dateInput);
      }
      else {
        throw new Error("Unsupported date input type");
      }
  
      // Validate the date
      if (isNaN(date.getTime())) {
        throw new Error("Invalid date result after conversion");
      }
  
      // Format the date
      const day = String(date.getUTCDate()).padStart(2, '0');
      const month = String(date.getUTCMonth() + 1).padStart(2, '0');
      const year = date.getUTCFullYear();
  
      const formattedDate = `${day}-${month}-${year}`;
      console.log(`Formatted date from ${JSON.stringify(dateInput)}: ${formattedDate}`);
      return formattedDate;
  
    } catch (error) {
      console.error(`Error formatting date:`, {
        input: dateInput,
        error: error.message,
        type: typeof dateInput
      });
      return '';
    }
  }