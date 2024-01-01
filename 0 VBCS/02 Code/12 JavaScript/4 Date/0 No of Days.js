dateValidationJs(fromDate, toDate) {

    console.log("fromDate==>"+fromDate);
    console.log("toDate==>"+toDate);
    let difference_In_Time = 0;
    let difference_In_Days =0;
    let date1 = new Date(fromDate);
    let date2 = new Date(toDate);
    // To calculate the time difference of two dates
    difference_In_Time = date2.getTime() - date1.getTime();
    console.log("difference_In_Time==>"+difference_In_Time);
    // To calculate the no. of days between two dates
    difference_In_Days = (difference_In_Time / (1000 * 3600 * 24)+1);
    console.log("difference_In_Days==>"+difference_In_Days);
    //To display the final no. of days (result)
    console.log("Total number of days between dates  <br>"
               	+ date1 + "<br> and <br>"
               	+ date2 + " is: <br> "
              	+ difference_In_Days
				);

    return difference_In_Days ;

    }
