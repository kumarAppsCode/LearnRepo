 getdate(value) {
     var date = new Date(value);
     var yy = String(date.getFullYear()).substring(2); // Get the last two digits of the year
     var mm = String(date.getMonth() + 1).padStart(2, '0'); // Add 1 to the month (as it's zero-based)
     var dd = String(date.getDate()).padStart(2, '0'); // Pad day with leading zero if needed
     var formattedDate = yy + '-' + mm + '-' + dd;
     console.log("value====>" + value);
     return formattedDate;
 };
