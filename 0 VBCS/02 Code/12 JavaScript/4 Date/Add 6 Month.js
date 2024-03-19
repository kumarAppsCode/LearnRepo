endDateAfterSixMonths(startdate) {
    // To set the start date to a variable
    let date1 = new Date(startdate);
    // Calculate the end date as six months later
    let endDate = new Date(date1);
    endDate.setMonth(endDate.getMonth() + 6);
    // Format the end date to 'YYYY-MM-DD'
    let formattedEndDate = endDate.toISOString().split('T')[0];
    // To display the final end date (result)
    console.log("End date after six months from <br>" + date1 + " is: <br>" + formattedEndDate);
    return formattedEndDate;
};

endDateminusSixMonths (startdate) {
    // To set the start date to a variable
    let date1 = new Date(startdate);
    // Calculate the end date as six months later
    let endDate = new Date(date1);
    endDate.setMonth(endDate.getMonth() - 6);
    // Format the end date to 'YYYY-MM-DD'
    let formattedEndDate = endDate.toISOString().split('T')[0];
    // To display the final end date (result)
    console.log("End date after six months from <br>" + date1 + " is: <br>" + formattedEndDate);
    return formattedEndDate;
};
