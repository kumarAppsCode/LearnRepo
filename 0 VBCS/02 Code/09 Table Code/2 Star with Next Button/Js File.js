define(['ojs/ojpagingdataproviderview','ojs/ojarraydataprovider'], 
function(PagingDataProviderView,ArrayDataProvider) {
  'use strict';

  class PageModule {
    //   pagingSearch(array) {
    //   var data = new PagingDataProviderView(new ArrayDataProvider(
    //   array, {
    //     idAttribute: 'person_id'
    //     }));
    //   return data;
    // };
     pagingSearch(array, pageSize = 200) {
    var data = new PagingDataProviderView(new ArrayDataProvider(array, {
      idAttribute: 'person_id',
      pageSize: pageSize  // Set the desired page size here
    }));
    return data;
  };



      pagingSearche(array) {
      var data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'person_id'
        }));
      return data;
    };
      pagingSubordinates(array) {
      var data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: ''
        }));
      return data;
    };

     deptExportToPdf (deptId, date) {
   let url= "http://143.47.185.0:8080/ReportDownload/qia/report/depttimeattendreport?P_DEPT_ID="+deptId+"&P_DATE="+date+"&pFileType=pdf";
    var win= window.open(url,'','scrollbars=no,menubar=no,height=600,width=800,resizable=yes,toolbar=no,location=no,status=no');
 win.location.reload();
  };

// saveFile (data, mimeType, filename) {
//     const blob = new Blob([data], {
//       type: mimeType
//     });
//     // IE/Edge
//     if (window.navigator && window.navigator.msSaveOrOpenBlob) {
//       window.navigator.msSaveOrOpenBlob(blob);
//       return;
//     }
//     var link = document.createElement('a');
//     link.href = URL.createObjectURL(blob);
//     link.download = filename;
//     link.click();
//     // Firefox: delay revoking the ObjectURL
//     setTimeout(function() {
  
//       URL.revokeObjectURL(blob);
//     }, 100);
//   };

  downloadFileFromBase64(base64String, name, type) {  
     var applicationType = "data:" + type + ";base64,";
	 var finalContent = applicationType + base64String;
	 const downloadLink = document.createElement('a');
	 document.body.appendChild(downloadLink);
	 downloadLink.href = finalContent;
	 downloadLink.download = name;
	 downloadLink.click();
     };
 
 getdate(value) {
  var date = new Date(value);
  var yy = String(date.getFullYear()).substring(2); // Get the last two digits of the year
  var mm = String(date.getMonth() + 1).padStart(2, '0'); // Add 1 to the month (as it's zero-based)
  var dd = String(date.getDate()).padStart(2, '0'); // Pad day with leading zero if needed

  var formattedDate = yy + '-' + mm + '-' + dd;
  console.log("value====>" + value);
  return formattedDate;
};

endDateAfterSixMonths (startdate) {
    // To set the start date to a variable
    var date1 = new Date(startdate);

    // Calculate the end date as six months later
    var endDate = new Date(date1);
    endDate.setMonth(endDate.getMonth() + 6);

    // Format the end date to 'YYYY-MM-DD'
    var formattedEndDate = endDate.toISOString().split('T')[0];

    // To display the final end date (result)
    console.log("End date after six months from <br>" + date1 + " is: <br>" + formattedEndDate);

    return formattedEndDate;
};


endDateminusSixMonths (startdate) {
    // To set the start date to a variable
    var date1 = new Date(startdate);

    // Calculate the end date as six months later
    var endDate = new Date(date1);
    endDate.setMonth(endDate.getMonth() - 6);

    // Format the end date to 'YYYY-MM-DD'
    var formattedEndDate = endDate.toISOString().split('T')[0];

    // To display the final end date (result)
    console.log("End date after six months from <br>" + date1 + " is: <br>" + formattedEndDate);

    return formattedEndDate;
};

// 
checkLinks(links) {
  let hasFirst = true;
  let hasPrev = true;
  let hasNext = true;
let lfirstoffset = 0;
let lprevoffset = 0;
let lnextoffset = 0;
 links.forEach(link => {
    if (link.rel === "first") {
     // hasFirst = false;
      const offsetMatch = link.href.match(/offset=(\d+)/);
      if (offsetMatch && offsetMatch[1] !== undefined) {
         hasFirst = false;
        lfirstoffset = parseInt(offsetMatch[1], 10);
      }
    } else if (link.rel === "prev") {
      //hasPrev = false;
      const offsetMatch = link.href.match(/offset=(\d+)/);
      if (offsetMatch && offsetMatch[1] !== undefined) {
        hasPrev = false;
        lprevoffset = parseInt(offsetMatch[1], 10);
      }
    } else if (link.rel === "next") {
      // hasNext = false;
      const offsetMatch = link.href.match(/offset=(\d+)/);
      if (offsetMatch && offsetMatch[1] !== undefined) {
        hasNext = false;
        lnextoffset = parseInt(offsetMatch[1], 10);
      }
    }
  });

  if (!hasFirst) {
    // Disable first link
    console.log("First link is missing or disabled.");
  }

  if (!hasPrev) {
    // Disable prev link
    console.log("Prev link is missing or disabled.");
  }

  if (!hasNext) {
    // Disable next link
    console.log("Next link is missing or disabled.");
  }
  console.log("lfirstoffset:", lfirstoffset);
console.log("lprevoffset:", lprevoffset);
console.log("lnextoffset:", lnextoffset);
return {
    lfirstoffset: lfirstoffset,
    lprevoffset: lprevoffset,
    lnextoffset: lnextoffset,
    hasPrev:hasPrev,
    hasNext:hasNext
  };
}

// subtraction
calculateSubtractionResult(operand1, operand2) {
    var subtractionResult = operand1 - operand2;
    console.log("Subtraction Result: " + subtractionResult);
    return subtractionResult;
};


 

  }
  
  return PageModule;
});
