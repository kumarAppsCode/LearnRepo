
  getSysdate(){
    let today = new Date();
    let dd = String(today.getDate()).padStart(2, '0');
    let mm = String(today.getMonth() + 1).padStart(2, '0'); // January is 0!
    let yyyy = today.getFullYear();
    let formattedDate =  dd+ '-' + mm + '-' + yyyy;
    return formattedDate;
  };


   getdate(value) {
  let date = new Date(value);
  let yy = String(date.getFullYear()).substring(2); // Get the last two digits of the year
  let mm = String(date.getMonth() + 1).padStart(2, '0'); // Add 1 to the month (as it's zero-based)
  let dd = String(date.getDate()).padStart(2, '0'); // Pad day with leading zero if needed
  let formattedDate = yy + '-' + mm + '-' + dd;
  console.log("value====>" + value);
  return formattedDate;
};
