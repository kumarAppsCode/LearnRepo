endDateAfterThirtyDays() {
    // Get the current date
    let sysdate = new Date();
    // Calculate the end date as 30 days later
    let endDate = new Date(sysdate);
    endDate.setDate(endDate.getDate() - 30);
    // Format the end date to 'YYYY-MM-DD'
    let formattedEndDate = endDate.toISOString().split('T')[0];
    // To display the final end date (result)
    console.log("End date 30 days from " + sysdate + " is: " + formattedEndDate);
    return formattedEndDate;
}
