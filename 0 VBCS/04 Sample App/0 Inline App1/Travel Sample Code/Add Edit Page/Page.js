define(['ojs/ojpagingdataproviderview', 'ojs/ojarraydataprovider'], function(PagingDataProviderView, ArrayDataProvider) {
  'use strict';

  class PageModule {
    pagingSearch(array) {
      let data = new PagingDataProviderView(new ArrayDataProvider(
        array, {
          idAttribute: 'travel_booking_id'
        }));
      return data;
    }

    pagingSearchHotel(array) {
      let data = new PagingDataProviderView(new ArrayDataProvider(
        array, {
          idAttribute: 'hotel_booking_id'
        }));
      return data;
    }

    pagingSearchPayment(array) {
      let data = new PagingDataProviderView(new ArrayDataProvider(
        array, {
          idAttribute: 'travel_payment_id'
        }));
      return data;
    }


 pagingRequiremore(array) {
      let data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'more_info_id'
        }));
      return data;
    };

    pagingSearchExpenditure(array) {
      let data = new PagingDataProviderView(new ArrayDataProvider(
        array, {
          idAttribute: 'travel_expenditure_id'
        }));
      return data;
    }
     paginghistory(array) {
      let data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'action_history_id'
        }));
      return data;
    }
    // 
     pagingSearchtraveldependent(array) {
      let data = new PagingDataProviderView(new ArrayDataProvider(
        array, {
          idAttribute: 'travel_dependent_id'
        }));
      return data;
    }
      pagingSearchtraveldependentpopup(array) {
      let data = new PagingDataProviderView(new ArrayDataProvider(
        array, {
          idAttribute: 'contact_relationship_id'
        }));
      return data;
    }

    // 

    WarningMsgAssign(array)
{
let test;
for(let i = 0; i < array.length; i++)
{
if(array[i].contact_relationship_id != null)
{
test = '1';
}
}
if(test === 1)
{
return '1';
}
else{
return '0';
}
};
    onPageNaviFun(naviValue) {
      let navi = null;

      if (naviValue === "CREATE") {
        navi = "POST";
      } else {
        navi = "PUT";
      }

      // console.log("navi==>"+navi);
      return navi;
    }

    getPrimaryKey(naviValue, keyValue) {
      let keyValueResult = null;

      console.log("naviValue Key===>" + naviValue);

      // console.log("Key===>"+keyValue);

      if (naviValue === "CREATE") {
        keyValueResult = "0";

        console.log("ADD==>" + keyValueResult);
      } else {
        keyValueResult = keyValue;
        console.log("ELS==>" + keyValueResult);
      }

      return keyValueResult;
    }

    // Field Disable on status & taskid

    validateFiled(status,userGroup, taskId, appType) {

      let emp_disable_access="false";
	    let fin_bind_access="false";
      let fin_actual_access="false";
      
      console.log("access==status==>"+status);
      console.log("access==userGroup==>"+userGroup);
      console.log("access==taskId==>"+taskId);
      console.log("access==appType==>"+appType);


      if(status=== "Draft"||status=== "Return for Correction"){
            console.log("access==1==>");
            emp_disable_access="false";
	          fin_bind_access="false";
            fin_actual_access="false";
      }else if(status=== "Reject"){
            console.log("access==1a==>");
            emp_disable_access="true";
	          fin_bind_access="false";
            fin_actual_access="false";
      }else if(status=== "Approved" && appType=== "IT"){
            console.log("access==2==>");
            emp_disable_access="true";
	          fin_bind_access="false";
            fin_actual_access="false";
      }else if(status=== "Approved" && appType=== "EMP"){
            console.log("access==3==>");
            emp_disable_access="true";
	          fin_bind_access="false";
            fin_actual_access="false";
      }else if((status=== "Pending" || status=== "Approver More Info" || status=== "Employee More Info") && appType=== "EMP"){
            console.log("access==4==>");
            emp_disable_access="true";
	          fin_bind_access="false";
            fin_actual_access="false";
      }else if((status=== "Pending" || status=== "Approver More Info" || status=== "Employee More Info") && appType=== "IT" && taskId!=null && 
      (userGroup ==="TRAVEL_SECTION"||userGroup ==="TRAVEL_SECTION_ASH_SHARQIYAH_SOUTH"||userGroup ==="TRAVEL_SECTION_AL SHARQIYAH SOUTH"||userGroup ==="TRAVEL_SECTION_MUSCAT"||userGroup ==="TRAVEL_SECTION_AL_BATINAH_SOUTH"||
      userGroup ==="TRAVEL_SECTION_AD_DAKHLIYAH"||userGroup ==="TRAVEL_SECTION_ASH_SHARQIYAH_NORTH"||userGroup ==="TRAVEL_SECTION_AL_SHARQIYAH_NORTH"||userGroup ==="TRAVEL_SECTION_AL_WUSTA"||userGroup ==="TRAVEL_SECTION_MUSANDAM"||
      userGroup ==="TRAVEL_SECTION_ADH_DHAHIRAH"||userGroup ==="TRAVEL_SECTION_AL_BURAYMI"||userGroup ==="TRAVEL_SECTION_HEAD_OFFICE"||userGroup ==="TRAVEL_SECTION_AL_BATINAH_NORTH"
      )
      ){
            console.log("access==5==>");
            emp_disable_access="true";
	          fin_bind_access="true";
            fin_actual_access="true";
      }else if((status=== "Pending" || status=== "Approver More Info" || status=== "Employee More Info") && appType=== "IT" && taskId!=null && 
      (userGroup ==="TRAVEL_SUPERVISOR_AL_SHARQIYAH_NORTH" || userGroup ==="TRAVEL_SUPERVISOR_AL_SHARQIYAH_SOUTH" || userGroup ==="TRAVEL_SUPERVISOR_AL_WASTA" || userGroup ==="TRAVEL_SUPERVISOR_AL_DHAHIRAH" || userGroup ==="TRAVEL_SUPERVISOR_AL_BATINAH_SOUTH" || userGroup ==="TRAVEL_SUPERVISOR_AL_DAKHLIYAH" || userGroup ==="TRAVEL_SUPERVISOR_MUSANDAM" || userGroup ==="TRAVEL_SUPERVISOR_AL_BURIMI" || userGroup ==="TRAVEL_SUPERVISOR_AL_BATINAH NORTH" || userGroup ==="TRAVEL_SUPERVISOR_MUSCAT")){
            console.log("access==5==>");
            emp_disable_access="true";
	          fin_bind_access="true";
            fin_actual_access="true";
      }else if((status=== "Pending" || status=== "Approver More Info" || status=== "Employee More Info") && appType=== "IT" && taskId!=null && (userGroup ==="HEAD_OF_ADMIN_OR_SS_MANAGER" || userGroup ==="HEAD_OF_ADMIN" || userGroup ==="TRAVEL_SUPERVISOR_MUSCAT_OR_HEAD_OF_ADMIN" )){
            console.log("access==5==>");
            emp_disable_access="true";
	          fin_bind_access="true";
            fin_actual_access="true";
      }else{
            console.log("access==6==>");
            emp_disable_access="true";
	          fin_bind_access="false";
            fin_actual_access="false";
      } 
      

    console.log("emp_disable==>access==>"+emp_disable_access);
    console.log("fin_bind==>access==>"+fin_bind_access);
    console.log("fin_actual_access==>access==>"+fin_actual_access);


      return {
              'emp_disable_access':emp_disable_access,
              'fin_bind_access':fin_bind_access,
              'fin_actual_access':fin_actual_access
            };
  };

    //  perdiem calculation
 calculateTotalpayableAmount(perdiem,perdiemdays) {


    return ((perdiem * perdiemdays)) ;
};


// -----variance calculation---------------
 calculateVariance(estcost,actcost) {


    return ((estcost-actcost)) ;
};

// calculating no.of.days

// noOfDaysBtnTwoDays (startdate,enddate) {

 // To set two dates to two variables

//     var difference_In_Time = 0;

//      var difference_In_Days =0;

//     var date1 = new Date(startdate);

//     var date2 = new Date(enddate);

     
    // To calculate the time difference of two dates

//     var difference_In_Time = date2.getTime() - date1.getTime();

     
    // To calculate the no. of days between two dates

//     var difference_In_Days = (difference_In_Time / (1000 * 3600 * 24)+1);

     
    //To display the final no. of days (result)

//     console.log("Total number of days between dates  <br>"

//                + date1 + "<br> and <br>"

//                + date2 + " is: <br> "

//                + difference_In_Days);

//                
// return difference_In_Days ;
//   };


// submitprocess

 getSubmitInstance(p_APPR_PROCESS, p_TRX_ID, p_USER_ID) {

      let callSubmitPackage="NO";
      let applicationName=null;
      let processName=null;
      let applicationVersion=null;

      if(window.location.href === "https://fa********.oraclecloud.com"){
         console.log("---PROD Approver--");
        applicationName="TravelRequestNew";
        processName="TravelProcess";
        applicationVersion="1.0";

       }else{
        console.log("---TEST Approver--");
        applicationName="TravelRequestNew";
        processName="TravelProcess";
        applicationVersion="1.0";

      
      }   

      return {
          'callSubmitPackage':callSubmitPackage,
          'applicationName':applicationName,
          'processName':processName,
          'applicationVersion':applicationVersion
      };

    }
  // calculating no.of.days
    calculateDateDifference(startDate, endDate) {
      // Convert the input dates to Date objects
      const startDateObj = new Date(startDate);
      const endDateObj = new Date(endDate);

        console.log("Sdate==>"+startDateObj);
        console.log("Edate==>"+endDateObj);

      // Calculate the time difference in milliseconds
      const timeDifference = endDateObj - startDateObj;

      // Calculate the number of days
      let daysDifference = Math.floor(timeDifference / (1000 * 60 * 60 * 24));

      // Check if the dates are the same
  if (daysDifference === 0) {
    // If the dates are the same, set daysDifference to 1
    daysDifference = 1;
  }

      return daysDifference;
    };
  }
  PageModule.prototype.attachmentTable = function(array) {
    var data = new PagingDataProviderView(new ArrayDataProvider(
    array, {
      idAttribute: 'document_id'
    }));
    return data;
  };
   
 


PageModule.prototype.downloadFileFromBase64 = function (base64String,name,type) {

    let applicationType = "data:"+type+";base64,";

    let finalContent = applicationType+base64String;

    const downloadLink = document.createElement('a');

    document.body.appendChild(downloadLink);

    downloadLink.href = finalContent;

    downloadLink.download =name;

    downloadLink.click();
  };
  return PageModule;
});


