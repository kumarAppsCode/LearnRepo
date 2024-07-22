define(['ojs/ojpagingdataproviderview','ojs/ojarraydataprovider'], 
function(PagingDataProviderView,ArrayDataProvider) {
  'use strict';

 class PageModule {

  //  pageSysDates() {
  //   var today = new Date();
  //   var dd = String(today.getDate()).padStart(2, '0');
  //   var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
  //   var yyyy = today.getFullYear();
  //   today = yyyy+'-'+mm+'-'+dd; 
  //   return today;
  // };

    /**
     *
     * @param {String} arg1
     * @return {String}
     */
    PagingFunction(array) {
      let data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'request_child_id'
        }));
      return data;
    };

    // On call Duty

//     calculateAllowanceAmountAfterDeduction (allowanceamt,deductionamt) {

//     var finalAllowanceAmount = 0;
//     var finalAllowanceAmount = allowanceamt - deductionamt;
//     console.log("Final Allowance Amount <br>" + finalAllowanceAmount);
//     return Number(Math.round(finalAllowanceAmount)) ;
// };	  

calculateAllowanceAmountAfterDeduction (allowanceamt,deductionamt) {

    let finalAllowanceAmount = allowanceamt - deductionamt;

    if (finalAllowanceAmount < 0) {
        finalAllowanceAmount = 0;
        console.log("Final Allowance Amount is negative. Setting to zero.");
    }

    console.log("Final Allowance Amount: " + finalAllowanceAmount);
    // return Math.round(finalAllowanceAmount);
     return finalAllowanceAmount;
};

// On call Duty date

getStartAndEndDates(input) {
  const monthStr = input.substring(0, 3).toUpperCase(); // Extract the month abbreviation
  const yearStr = input.substring(4); // Extract the characters after the dash

  const monthMap = {
    // 'JAN': 'Jan', 'FEB': 'Feb', 'MAR': 'Mar', 'APR': 'Apr', 'MAY': 'May', 'JUN': 'Jun',
    // 'JUL': 'Jul', 'AUG': 'Aug', 'SEP': 'Sep', 'OCT': 'Oct', 'NOV': 'Nov', 'DEC': 'Dec'
    'JAN': '01', 'FEB':'02', 'MAR': '03', 'APR': '04', 'MAY': '05', 'JUN': '06',
    'JUL':'07', 'AUG': '08', 'SEP': '09', 'OCT': '10', 'NOV': '11', 'DEC': '12'
  };

  const month = monthMap[monthStr.toUpperCase()];
  const year = parseInt(yearStr);

  //const startDate = `01-${month}-${year}`;
  const startDate = `${year}-${month}-01`;
  const lastDay = new Date(year, parseInt(Object.keys(monthMap).indexOf(monthStr.toUpperCase())) + 1, 0).getDate();
  //const endDate = `${lastDay}-${month}-${year}`;
  const endDate = `${year}-${month}-${lastDay}`;
console.log("Start Date:",startDate);
console.log("End Date:",endDate);
  return {
    startDate: startDate,
    endDate: endDate
  };
}
formatDate(inputDate) {
  const date = new Date(inputDate);
  const options = { day: '2-digit', month: 'short', year: 'numeric' };
  const formattedDate = date.toLocaleDateString('en-US', options);
  console.log("StartDate:",formattedDate);
  return {
    formattedDate: formattedDate
  };
}



calculateDeductedAmount (noofdays,perdayamt) {

   let deductedeAmount = 0;
   deductedeAmount = noofdays * Number(perdayamt);
    console.log("Allowance Amount <br>" + deductedeAmount);
    //return Number(Math.round(deductedeAmount)) ;
    return deductedeAmount;
};	   



// 
removeTimeZone(startdate, enddate) {
    // Remove the time zone part
    const dateWithoutTimeZonestart = startdate.replace("T00:00:00Z", "");
    const dateWithoutTimeZoneend = enddate.replace("T00:00:00Z", "");

    return {
        dateWithoutTimeZonestart: dateWithoutTimeZonestart,
        dateWithoutTimeZoneend: dateWithoutTimeZoneend
    };
}
    // Dependent Attachment table

    pagingAttachmentSearch (array) {
      let data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'attachment_id'
        }));
      return data;
    };


    downloadFileFromBase64function (base64String,name,type)
   {
    let applicationType = "data:"+type+";base64,";
    let finalContent = applicationType+base64String;
    const downloadLink = document.createElement('a');
    document.body.appendChild(downloadLink);
    downloadLink.href = finalContent;
    downloadLink.download =name;
    downloadLink.click();
    };


pagingChildSearchfunction(array) {
      let data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'request_child_id'
        }));
      return data;
    };

EmployeepagingSearchfunction(array) {
      let data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'person_id'
        }));
      return data;
    };

// Image Conversion Function

imageconversion (input) {
   // Replace 'imageDataString' with the actual image data string
        const imageDataString = input;

        // Create a new Image object
        const img = new Image();

        // Set the image source to the image data
        img.src = "data:image/png;base64," + imageDataString;

        // Add the image to your <img> tag once it's loaded
        img.onload = function() {
            const myImageTag = document.getElementById("myImage");
            myImageTag.setAttribute("src", img.src);
        };
};



    WarningMsgAssignfunction (array)
{
  let test;
  for(let i = 0; i < array.length; i++)
  {
    if(array[i].person_id !==null)
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
    
downloadFileFromBase64 (base64String,name,type) {

    let applicationType = "data:"+type+";base64,";

    let finalContent = applicationType+base64String;

    const downloadLink = document.createElement('a');

    document.body.appendChild(downloadLink);

    downloadLink.href = finalContent;

    downloadLink.download =name;

    downloadLink.click();
    

  

  };


  onPageNaviFun (naviValue) {
        let navi=null;
        if(naviValue==="CREATE"){
          navi="POST";
        }else{
        navi="PUT";
      }
   // console.log("navi==>"+navi);
    return navi;
  };
WarningMsgAssign(array)
{
  let test;
  for(let i = 0; i < array.length; i++)
  {
    if(array[i].person_id !=null)
    {
    test = '1';
    }
  }
if(test == 1)
{
  return '1';
}
else{
  return '0';
}
};

TableRefresh () {

  document.getElementById('absencetable').refresh();

  };


  getPrimaryKey  (naviValue, keyValue) {
    let keyValueResult=null;
    console.log("naviValue Key===>"+naviValue);
    // console.log("Key===>"+keyValue);
    if(naviValue==="CREATE"){
        keyValueResult="0";
       console.log("ADD==>"+keyValueResult);
    }else{
      keyValueResult=keyValue;
     console.log("ELS==>"+keyValueResult);
    }
    return keyValueResult;
    
  };
  isFormValid(form) {
let tracker = document.getElementById(form);
if (tracker.valid === "valid") {
  return true;
} else {
tracker.showMessages();
tracker.focusOn("@firstInvalidShown");
return false;
}
};


     pagingLine(array) {
      let data = new PagingDataProviderView(new ArrayDataProvider(
        array, {
          idAttribute: 'document_id'
        }
      ));
      return data;
    };


  validateJsonData(jsonObj, requestType) {

    let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    console.log("Json-->objValidattion==>"+obj);
    // console.log("Object Length==>"+obj.length);
    // console.log("==>==>>"+Object.keys(json).length);

    if(Object.keys(json).length==0){
      console.log("0000000000");
      return {
            'isValid': "true",
            'message': 'Please fill out the required fields.'
      };
    }else{
        console.log("1111111111111");
          if(requestType==="COVID_VACCINATION_REQUEST"){
              return  PageModule.prototype.validateCovid(jsonObj);
          }else if(requestType==="EQUIPMENT_REQUEST"){
              return   PageModule.prototype.validateEquipment(jsonObj);
          }else if(requestType==="MATERIAL_ACCESS_REQUEST"){
              return   PageModule.prototype.validateMaterialaccess(jsonObj);
          }else if(requestType==="MATERIAL_REMOVAL_REQUEST"){
              return   PageModule.prototype.validateMaterialremoval(jsonObj);
          }else if(requestType==="TEMPORARY_ACCESS_PERMIT_FOR_CONTRACTOR_VISITOR"){
              return   PageModule.prototype.validateTapc(jsonObj);
          }else if(requestType==="TEMPORARY_ACCESS_PERMIT_FOR_EMPLOYEE"){
              return   PageModule.prototype.validateTape(jsonObj);
          }else if(requestType==="STUDY_HOUR_REQUEST"){
              return   PageModule.prototype.validateStudyhour(jsonObj);
          }else if(requestType==="SHORT_TERM_LOAN_REQUEST"){
              return   PageModule.prototype.validateStlr(jsonObj);
          }else if(requestType==="CHILDREN_EDUCATION_REQUEST"){
              return   PageModule.prototype.validateCde(jsonObj);
          }else if(requestType==="SECONDMENT_REQUEST"){
              return   PageModule.prototype.validateSecondmentRequest(jsonObj);
          }else if(requestType==="STAFF_ACCESS_CARD"){
              return   PageModule.prototype.validateStaffaccessrequest(jsonObj);
          }else if(requestType==="FEEDING_HOURS"){
              return   PageModule.prototype.validateFeedinghours(jsonObj); 
          }else if(requestType==="VEHICLE_REQUEST"){
              return   PageModule.prototype.validateVehiclerequest(jsonObj);
          }else if(requestType==="ON_CALL_DUTY"){
              return   PageModule.prototype.validateOncallduty(jsonObj);
          }else if(requestType==="ACADEMIC_STUDY_PROCESS"){
              return   PageModule.prototype.validateAcademicstudy(jsonObj);
          }else if(requestType==="MOVEMENT_REQUEST"){
              return   PageModule.prototype.validateMovementrequest(jsonObj);
          }else if(requestType==="ACTING_ALLOWANCE"){
              return   PageModule.prototype.validateActingallowance(jsonObj);
          }else if(requestType==="BUSINESS_CARD_REQUEST"){
              return   PageModule.prototype.validateBusinessRequest(jsonObj);
              
                                          
          }else{
            return {
              'isValid':"true",
              'message':'NONE'
            };
          }


    }
  };
validateOncallduty(jsonObj){
    let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;

       if(typeof(json.ldata.ocd_month_and_year) !== "undefined" && json.ldata.ocd_month_and_year !== null){
       
                  isValid="true";
                  message='null';
              }else{
                isValid="false";
                message='Please Select the Month and Year';                
              }

    return {
        'isValid':isValid,
        'message':message
    };
}


validateCovid(jsonObj) {
    let obj = JSON.stringify(jsonObj);
    let json = JSON.parse(obj);
    let isValid = "false";
    let message = null;

    if (typeof(json.ldata.vaccination_status) !== "undefined" && json.ldata.vaccination_status !== null) {
        
        if (json.ldata.vaccination_status === "Done") { // Check if vaccination status is "Done"
            if (typeof(json.ldata.vaccination_date) !== "undefined" && json.ldata.vaccination_date !== null) {
                if (typeof(json.ldata.vaccine_region) !== "undefined" && json.ldata.vaccine_region !== null) {
                    isValid = "true";
                    message = null; // or you can set a different message
                } else {
                    isValid = "false";
                    message = 'Please Select the Vaccine Region';
                }
            } else {
                isValid = "false";
                message = 'Please Select the Date';
            }
        } else {
            // If vaccination status is not "Done"
            if (typeof(json.ldata.vaccination_reason) !== "undefined" && json.ldata.vaccination_reason !== null) {
                isValid = "true";
                message = null; // or you can set a different message
            } else {
                isValid = "false";
                message = 'Please Enter the Reason';
            }
        }
    } else {
        isValid = "false";
        message = 'Please Select the Status';
    }

    return {
        'isValid': isValid,
        'message': message
    };
}


validateEquipment(jsonObj){
    let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;

    
    if(typeof(json.ldata.eq_equipment_type) !== "undefined" && json.ldata.eq_equipment_type !== null){
       if(typeof(json.ldata.eq_vehicle_type) !== "undefined" && json.ldata.eq_vehicle_type !== null){
          if(typeof(json.ldata.eq_mobile) !== "undefined" && json.ldata.eq_mobile !== null){
              if(typeof(json.ldata.eq_request_description) !== "undefined" && json.ldata.eq_request_description !== null){
                if(typeof(json.ldata.eq_for_location) !== "undefined" && json.ldata.eq_for_location !== null){
                  // if(typeof(json.ldata.eq_request_description) !== "undefined" && json.ldata.eq_request_description !== null){
                    if(typeof(json.ldata.eq_date_from) !== "undefined" && json.ldata.eq_date_from !== null){
                      // if(typeof(json.ldata.eq_time_from_hours) !== "undefined" && json.ldata.eq_time_from_hours !== null){
                      //   if(typeof(json.ldata.eq_time_from_minutes) !== "undefined" && json.ldata.eq_time_from_minutes !== null){
                          if(typeof(json.ldata.eq_date_to) !== "undefined" && json.ldata.eq_date_to !== null){
                            // if(typeof(json.ldata.eq_time_to_hours) !== "undefined" && json.ldata.eq_time_to_hours !== null){
                            //   if(typeof(json.ldata.eq_time_to_minutes) !== "undefined" && json.ldata.eq_time_to_minutes !== null){
                  isValid="true";
                  message='null';
          //     }else{
          //       isValid="false";
          //       message='Please Select the Time to Minutes';                
          //     }
          // } else{
          //   isValid="false";
          //   message='Please Select the Time to Hours ';                     
          // } 
       }else{
          isValid="false";
          message='Please Select the End Date';         
       } 
    // }else{
    //     isValid="false";
    //     message='Please Select the Time from Minutes';
    //   }
    // }else{
    //     isValid="false";
    //     message='Please Select the Time from Hours';
    // }
  }else{
        isValid="false";
        message='Please Select the Start Date';
    }  
  }else{
        isValid="false";
        message='Please Enter the For Location'; 
  }
   }else{
        isValid="false";
        message='Please Enter the Request Description';
   }
    }else{
        isValid="false";
        message='Please Enter the Mobile Number';
    }
     }else{
        isValid="false";
        message='Please Select the Vehicle Type';
     }
      }else{
        isValid="false";
        message='Please Select the Equipment Type';
      }

    return {
        'isValid':isValid,
        'message':message
    };
    // $chain.results.callFunctionValidateJsonData.isValid + "-" + $chain.results.callFunctionValidateJsonData.message
    // $chain.results.callFunctionValidateJsonData.isValid!=="false"?true:false   
}


validateMaterialaccess(jsonObj){
    let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;
   

    if (jsonObj.ldata.ma_department !== undefined && jsonObj.ldata.ma_department !== null) {
        if (jsonObj.ldata.ma_company_name !== undefined && jsonObj.ldata.ma_company_name !== null) {
            if (jsonObj.ldata.ma_contact_no !== undefined && jsonObj.ldata.ma_contact_no !== null) {
                if (jsonObj.ldata.ma_start_date !== undefined && jsonObj.ldata.ma_start_date !== null) {
                    if (jsonObj.ldata.ma_end_date !== undefined && jsonObj.ldata.ma_end_date !== null) {
                        if (jsonObj.ldata.ma_description !== undefined && jsonObj.ldata.ma_description !== null) {
                            if (jsonObj.ldata.ma_quantity !== undefined && jsonObj.ldata.ma_quantity !== null) {
                                if (jsonObj.ldata.ma_region !== undefined && jsonObj.ldata.ma_region !== null) {
                                    if (jsonObj.ldata.ma_wilayat !== undefined && jsonObj.ldata.ma_wilayat !== null) {
                                        if (jsonObj.ldata.ma_region !== null) {
                                            if (jsonObj.ldata.ma_wilayat !== undefined && jsonObj.ldata.ma_wilayat !== null) {
                                                isValid = "true";
                                                message = null;
                                            } else {
                                                isValid = "false";
                                                message = "Please Select the Wilayat";
                                            }
                                        } else {
                                            isValid = "true";
                                            message = null;
                                        }

                                        if (jsonObj.ldata.ma_site !== undefined && jsonObj.ldata.ma_site !== null) {
                                            if (jsonObj.ldata.ma_site === "Others") {
                                                if (jsonObj.ldata.ma_remarks !== undefined && jsonObj.ldata.ma_remarks !== null) {
                                                    isValid = "true";
                                                    message = null;
                                                } else {
                                                    isValid = "false";
                                                    message = "Please Enter The Remarks";
                                                }
                                            } else {
                                                isValid = "true";
                                                message = null;
                                            }
                                        } else {
                                            isValid = "false";
                                            message = "Please Select the Site";
                                        }
                                    } else {
                                        isValid = "false";
                                        message = "Please Select the Wilayat";
                                    }
                                } else {
                                    isValid = "false";
                                    message = "Please Select the Region";
                                }
                            } else {
                                isValid = "false";
                                message = "Please Select the Quantity";
                            }
                        } else {
                            isValid = "false";
                            message = "Please Enter the Description";
                        }
                    } else {
                        isValid = "false";
                        message = "Please Select the End Date";
                    }
                } else {
                    isValid = "false";
                    message = "Please Select the Start Date";
                }
            } else {
                isValid = "false";
                message = "Please Enter the Contact No";
            }
        } else {
            isValid = "false";
            message = "Please Enter the Company Name";
        }
    } else {
        isValid = "false";
        message = "Please Enter the Department";
    }

    return {
        isValid: isValid,
        message: message,
    };
}




validateMaterialremoval(jsonObj){
    let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;

       if(typeof(json.ldata.mrr_department) !== "undefined" && json.ldata.mrr_department !== null){
    if(typeof(json.ldata.mrr_company_name) !== "undefined" && json.ldata.mrr_company_name !== null){
    if(typeof(json.ldata.mrr_contact_no) !== "undefined" && json.ldata.mrr_contact_no !== null){  
    if(typeof(json.ldata.mrr_start_date) !== "undefined" && json.ldata.mrr_start_date !== null){
    if(typeof(json.ldata.mrr_end_date) !== "undefined" && json.ldata.mrr_end_date !== null){ 
    if(typeof(json.ldata.mrr_description) !== "undefined" && json.ldata.mrr_description !== null){  
    if(typeof(json.ldata.mrr_quantity) !== "undefined" && json.ldata.mrr_quantity !== null){ 
    // if(typeof(json.ldata.mrr_unit_of_measure) !== "undefined" && json.ldata.mrr_unit_of_measure !== null){ 
    if(typeof(json.ldata.mrr_region) !== "undefined" && json.ldata.mrr_region !== null){
      if(typeof(json.ldata.mrr_site) !== "undefined" && json.ldata.mrr_site !== null){  

    


    

    if (json.ldata.mrr_site == "Others") {
                                            if (typeof(json.ldata.mrr_remarks) !== "undefined" && json.ldata.mrr_remarks !== null) {
                                                isValid = "true";
                                                message = null;
                                            } else {
                                                isValid = "false";
                                                message = "Please Enter The Remarks";
                                            }
                                        } else {
                                            isValid = "true";
                                            message = null;
                                        }
 if (json.ldata.mrr_region !==null ) {
                                            if (typeof(json.ldata.mrr_wilayat) !== "undefined" && json.ldata.mrr_wilayat !== null) {
                                                isValid = "true";
                                                message = null;
                                            } else {
                                                isValid = "false";
                                                message = "Please Select The Wilayat";
                                            }
                                        } else {
                                            isValid = "true";
                                            message = null;
                                        }  

if (json.ldata.mrr_site == "Others") {
                                            if (typeof(json.ldata.mrr_remarks) !== "undefined" && json.ldata.mrr_remarks !== null) {
                                                isValid = "true";
                                                message = null;
                                            } else {
                                                isValid = "false";
                                                message = "Please Enter The Remarks";
                                            }
                                        } else {
                                            isValid = "true";
                                            message = null;
                                        }
      
                                       

                }else{
                isValid="false";
                message='Please Select the Site';                
              }
                  
              }else{
                isValid="false";
                message='Please Select the Region';                
              }
              // }else{
              //   isValid="false";
              //   message='Please Select the Unit of Measure';                
              // } 
              }else{
                isValid="false";
                message='Please Enter the Quantity';                
              }
             } else{
                isValid="false";
                message='Please Enter the Description';                
              } 
              } else{
                isValid="false";
                message='Please Select the End Date';                
              } 
              } else{
                isValid="false";
                message='Please Select the Start Date';                
              }  
              }  else{
                isValid="false";
                message='Please Enter the Contact No';                
              }
              }else{
                isValid="false";
                message='Please Enter the Company Name';                
              }
              }else{
                isValid="false";
                message='Please Enter the Department';                
              } 

                return {
        'isValid':isValid,
        'message':message
    };
}



validateTapc(jsonObj){
    let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;
    if(typeof(json.ldata.tapc_organization_name) !== "undefined" && json.ldata.tapc_organization_name !== null){
    if(typeof(json.ldata.tapc_start_date_of_visit) !== "undefined" && json.ldata.tapc_start_date_of_visit !== null){
    if(typeof(json.ldata.tapc_end_date_of_visit) !== "undefined" && json.ldata.tapc_end_date_of_visit !== null){
    if(typeof(json.ldata.tapc_reason_of_visit) !== "undefined" && json.ldata.tapc_reason_of_visit !== null){  
    if(typeof(json.ldata.tapc_region) !== "undefined" && json.ldata.tapc_region !== null){
    if(typeof(json.ldata.tapc_wilayat) !== "undefined" && json.ldata.tapc_wilayat !== null){ 
    if(typeof(json.ldata.tapc_site) !== "undefined" && json.ldata.tapc_site !== null){  
    
     isValid="true";
                  message='null';
              }
else{
                isValid="false";
                message='Please Select the Site';                
              }
              }else{
                isValid="false";
                message='Please Select the Wilayat';                
              } 
              }else{
                isValid="false";
                message='Please Select the Region';                
              }
             } else{
                isValid="false";
                message='Please Select the Reason of Visit';                
              } 
              } else{
                isValid="false";
                message='Please Select the End Date';                
              } 
              } else{
                isValid="false";
                message='Please Select the Start Date';                
              }
              } else{
                isValid="false";
                message='Please Enter the Organization Name';                
              }


               return {
        'isValid':isValid,
        'message':message
    };
}





 
 

validateTape(jsonObj) {
    let obj = JSON.stringify(jsonObj);
    let json = JSON.parse(obj);
    let isValid = "false";
    let message = null;

     if (typeof json.ldata.tape_start_date_of_visit !== "undefined" && json.ldata.tape_start_date_of_visit !== null) {
        if (typeof json.ldata.tape_end_date_of_visit !== "undefined" && json.ldata.tape_end_date_of_visit !== null) {
            if (typeof json.ldata.tape_reason_of_visit !== "undefined" && json.ldata.tape_reason_of_visit !== null) {
                if (typeof json.ldata.tape_region !== "undefined" && json.ldata.tape_region !== null) {
                    if (typeof json.ldata.tape_wilayat !== "undefined" && json.ldata.tape_wilayat !== null) {
                        if (json.ldata.tape_wilayat === "All Wilayat") {
                            if (typeof json.ldata.tape_reason !== "undefined" && json.ldata.tape_reason !== null) {
                                isValid = "true";
                                message = null;
                            } else {
                                isValid = "false";
                                message = "Please Enter The Remarks";
                            }
                        } else {
                            isValid = "true";
                            message = null;
                        }

                        // Check tape_site after tape_wilayat
                        if (typeof json.ldata.tape_site !== "undefined" && json.ldata.tape_site !== null) {
                            isValid = "true";
                            message = null;
                        } else {
                            isValid = "false";
                            message = "Please Enter the Site";
                        }
                    } else {
                        isValid = "false";
                        message = "Please Select the Wilayat";
                    }
                } else {
                    isValid = "false";
                    message = "Please Select the Region";
                }
            } else {
                isValid = "false";
                message = "Please Select the Reason of Visit";
            }
        } else {
            isValid = "false";
            message = "Please Select the End Date of Visit";
        }
    } else {
        isValid = "false";
        message = "Please Select the Start Date of Visit";
    }

    // Check if tape_wilayat contains 'All Wilayat', then tape_reason should contain data
    if (json.ldata.tape_wilayat === "All Wilayat" && (typeof json.ldata.tape_reason === "undefined" || json.ldata.tape_reason === null)) {
        isValid = "false";
        message = "Please Enter The Remarks";
    }

    return {
        isValid: isValid,
        message: message,
    };
}



// validatePperequest(jsonObj){
//     let obj = JSON.stringify(jsonObj);
//     let json= JSON.parse(obj);
//     let isValid="false";
//     let message=null;

//      if(typeof(json.ldata.pper_item) !== "undefined" && json.ldata.pper_item !== null){
//     if(typeof(json.ldata.pper_quantity) !== "undefined" && json.ldata.pper_quantity !== null){
//     if(typeof(json.ldata.pper_employee_location) !== "undefined" && json.ldata.pper_employee_location !== null){  
    
//     isValid="true";
//                   message='null';
//               }
//            else{
//                 isValid="false";
//                 message='Please Enter the Employee Location';                
//               }
//               }else{
//                 isValid="false";
//                 message='Please Select the Quantity';                
//               } 
//               }else{
//                 isValid="false";
//                 message='Please Select the Item';                
//               }
   
//    return {
//         'isValid':isValid,
//         'message':message
//     };
// }

validateStudyhour(jsonObj){
    let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;

if(typeof(json.ldata.shr_semester_start_date) !== "undefined" && json.ldata.shr_semester_start_date !== null){
if(typeof(json.ldata.shr_semester_end_date) !== "undefined" && json.ldata.shr_semester_end_date !== null){
if(typeof(json.ldata.shr_start_time) !== "undefined" && json.ldata.shr_start_time !== null){
if(typeof(json.ldata.shr_sunday) !== "undefined" && json.ldata.shr_sunday !== null){
if(typeof(json.ldata.shr_monday) !== "undefined" && json.ldata.shr_monday !== null){
if(typeof(json.ldata.shr_tuesday) !== "undefined" && json.ldata.shr_tuesday !== null){
if(typeof(json.ldata.shr_wednesday) !== "undefined" && json.ldata.shr_wednesday !== null){
if(typeof(json.ldata.shr_thursday) !== "undefined" && json.ldata.shr_thursday !== null){          
          
    
    isValid="true";
                  message='null';
              }
           else{
                isValid="false";
                message='Please Select the Thursday';                
              }   
           }else{
                isValid="false";
                message='Please Select the Wednesday';                
              }   
           }else{
                isValid="false";
                message='Please Select the Tuesday';                
              }   
           }else{
                isValid="false";
                message='Please Select the Monday';                
              }   
           }else{
                isValid="false";
                message='Please Select the Sunday';                
              }   
           }else{
                isValid="false";
                message='Please Select the Time';                
              }   
           }else{
                isValid="false";
                message='Please Select the Semester End Date';                
              }
              }else{
                isValid="false";
                message='Please Select the Semester Start Date';                
              }

              return {
        'isValid':isValid,
        'message':message
    };

  }

validateStlr(jsonObj){
    let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;

    
if(typeof(json.ldata.stlr_loan_amount) !== "undefined" && json.ldata.stlr_loan_amount !== null){
    if(typeof(json.ldata.stlr_installment_start_date) !== "undefined" && json.ldata.stlr_installment_start_date !== null){
      if(typeof(json.ldata.stlr_installment_duration) !== "undefined" && json.ldata.stlr_installment_duration !==null){
    
    isValid="true";
                  message='null';
              }
           else{
                isValid="false";
                message='Please Select the Installment Duration';                
              }
              }else{
                isValid="false";
                message='Please Select the Installment Start Date';                
              }
              }else{
                isValid="false";
                message='Please Select the Loan Amount';   
              }

              return {
        'isValid':isValid,
        'message':message
    };

  }

  
validateCde(jsonObj){
    let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;

    if(typeof(json.ldata.cer_name_of_the_kid) !== "undefined" && json.ldata.cer_name_of_the_kid !== null){
    if(typeof(json.ldata.cer_academic_year) !== "undefined" && json.ldata.cer_academic_year !== null){
    if(typeof(json.ldata.cer_eligible_amount) !== "undefined" && json.ldata.cer_eligible_amount !== null){
    if(typeof(json.ldata.cer_name_of_the_school) !== "undefined" && json.ldata.cer_name_of_the_school !== null){
    if(typeof(json.ldata.cer_school_fees) !== "undefined" && json.ldata.cer_school_fees !==null){
    if(typeof(json.ldata.cer_invoice_number) !== "undefined" && json.ldata.cer_invoice_number !==null){
    if(typeof(json.ldata.cer_invoice_receipt_available) !== "undefined" && json.ldata.cer_invoice_receipt_available !==null){

       isValid="true";
                  message='null';
              }
           else{
                isValid="false";
                message='Please Select the Invoice Receipt Available';                
              }
              }else{
                isValid="false";
                message='Please Enter the Invoice Number';                
              }
              }else{
                isValid="false";
                message='Please Enter the School Fees';   
              }
             }else{
                isValid="false";
                message='Please Enter the Name the of School';   
              }
              }else{
                isValid="false";
                message='Please Enter the Eligible Amount';   
              }
             }else{
                isValid="false";
                message='Please Select the Academic Year';   
              } 
              }else{
                isValid="false";
                message='Please Enter the Name of the Kid';   
              }    

   return {
        'isValid':isValid,
        'message':message
    };

  }
  

  validateSecondmentRequest(jsonObj){
    let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;

if(typeof(json.ldata.sr_proposed_directorate) !== "undefined" && json.ldata.sr_proposed_directorate !== null){
if(typeof(json.ldata.sr_proposed_directorate_position) !== "undefined" && json.ldata.sr_proposed_directorate_position !== null){
if(typeof(json.ldata.sr_proposed_position) !== "undefined" && json.ldata.sr_proposed_position !== null){
        


       isValid="true";
                  message='null';
              }

  else{
                isValid="false";
                message='Please Select the Proposed Directorate';   
              }
            }else{
                isValid="false";
                message='Please Select the Proposed Directorate Position';                
              }
            }else{
                isValid="false";
                message='Please Enter the Proposed Position';                
              }  
              return {
        'isValid':isValid,
        'message':message
    };

  }


validateMovementrequest(jsonObj){
    let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;

    if(typeof(json.ldata.mr_proposed_directorate) !== "undefined" && json.ldata.mr_proposed_directorate !== null){
if(typeof(json.ldata.mr_proposed_directorate_position) !== "undefined" && json.ldata.mr_proposed_directorate_position !== null){
if(typeof(json.ldata.mr_proposed_position) !== "undefined" && json.ldata.mr_proposed_position !== null){
        


       isValid="true";
                  message='null';
              }

  else{
                isValid="false";
                message='Please Enter the Proposed Position';   
              }
            }else{
                isValid="false";
                message='Please Select the Proposed Directorate Position';                
              }
            }else{
                isValid="false";
                message='Please Select the Proposed Directorate';                
              }  
              return {
        'isValid':isValid,
        'message':message
    };

  }


  

validateStaffaccessrequest(jsonObj){
    let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;

    if(typeof(json.ldata.sac_reason) !== "undefined" && json.ldata.sac_reason !== null){
    if(typeof(json.ldata.sac_remarks) !== "undefined" && json.ldata.sac_remarks !== null){  


       isValid="true";
                  message='null';
              }

  else{
                isValid="false";
                message='Please Select the Remarks';   
              }

            }else{
                isValid="false";
                message='Please Select the Reason';   
              }  

              return {
        'isValid':isValid,
        'message':message
    };

  }


// This Function is for Temporary Access Permit Fot Contractor/ Visitor

// validateTapcChild(jsonObj){
//     let obj = JSON.stringify(jsonObj);
//     let json= JSON.parse(obj);
//     let isValid="false";
//     let message=null;
//     if(typeof(json.ldata.tapc_visitor_name) !== "undefined" && json.ldata.tapc_visitor_name !== null){
//        if(typeof(json.ldata.tapc_id_number) !== "undefined" && json.ldata.tapc_id_number !== null){
//           if(typeof(json.ldata.tapc_job_desigination) !== "undefined" && json.ldata.tapc_job_desigination !== null){
//                   isValid="true";
//                   message='null';
//           } else{
//             isValid="false";
//             message='Please Enter the Job Designation';                     
//           } 
//        }else{
//           isValid="false";
//           message='Please Enter Id Number';         
//        } 
//     }else{
//         isValid="false";
//         message='Please Enter the Visitor Name';
//     }

//     return {
//         'isValid':isValid,
//         'message':message
//     };
// };

validateFeedinghours(jsonObj){
let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;


if(typeof(json.ldata.fh_start_date) !== "undefined" && json.ldata.fh_start_date !== null){
          if(typeof(json.ldata.fh_end_date) !== "undefined" && json.ldata.fh_end_date !== null){
                  isValid="true";
                  message='null';
          } else{
            isValid="false";
            message='Please Select the End Date';                     
          } 
       }else{
          isValid="false";
          message='Please Select the Start Date';         
       } 

  return {
        'isValid':isValid,
        'message':message
    };
}

validateVehiclerequest(jsonObj){
let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;

    if(typeof(json.ldata.vr_request_type) !== "undefined" && json.ldata.vr_request_type !== null){
    if(typeof(json.ldata.vr_vehicle_type) !== "undefined" && json.ldata.vr_vehicle_type !== null){
    if(typeof(json.ldata.vr_request_for_contractor) !== "undefined" && json.ldata.vr_request_for_contractor !== null){  
    // if(typeof(json.ldata.vr_vehicle_category) !== "undefined" && json.ldata.vr_vehicle_category !== null){
    if(typeof(json.ldata.vr_mobile_number) !== "undefined" && json.ldata.vr_mobile_number !== null){ 
    if(typeof(json.ldata.vr_request_description) !== "undefined" && json.ldata.vr_request_description !== null){  
    if(typeof(json.ldata.vr_requestor_location) !== "undefined" && json.ldata.vr_requestor_location !== null){ 
    if(typeof(json.ldata.vr_to_location) !== "undefined" && json.ldata.vr_to_location !== null){ 
    if(typeof(json.ldata.vr_date_from) !== "undefined" && json.ldata.vr_date_from !== null){
    if(typeof(json.ldata.vr_time_from_hours) !== "undefined" && json.ldata.vr_time_from_hours !== null){
    // if(typeof(json.ldata.vr_time_from_minutes) !== "undefined" && json.ldata.vr_time_from_minutes !== null){
    if(typeof(json.ldata.vr_date_to) !== "undefined" && json.ldata.vr_date_to !== null){
    if(typeof(json.ldata.vr_time_to_hours) !== "undefined" && json.ldata.vr_time_to_hours !== null){
    // if(typeof(json.ldata.vr_time_to_minutes) !== "undefined" && json.ldata.vr_time_to_minutes !== null){

                  isValid="true";
                  message='null';
              // }else{
              //   isValid="false";
              //   message='Please Select the Time to Minutes';                
              // }
               }else{
                isValid="false";
                message='Please Select the Time to Hours';                
              }
               }else{
                isValid="false";
                message='Please Select the Date to';                
              }
              //  }else{
              //   isValid="false";
              //   message='Please Select the Time from Minutes';                
              // }
               }else{
                isValid="false";
                message='Please Select the Time fro Hours';                
              }
               }else{
                isValid="false";
                message='Please Select the Date from';                
              }
              }else{
                isValid="false";
                message='Please Enter the To Location';                
              } 
              }else{
                isValid="false";
                message='Please Select the Requestor Location';                
              }
             } else{
                isValid="false";
                message='Please Enter the Request Description';                
              } 
              } else{
                isValid="false";
                message='Please Enter the Mobile Number';                
              } 
              // } else{
              //   isValid="false";
              //   message='Please Select the Vehicle category';                
              // }  
              }  else{
                isValid="false";
                message='Please Select the Request Made For Contractor';                
              }
              }else{
                isValid="false";
                message='Please Select the Vehicle type';                
              }
              }else{
                isValid="false";
                message='Please Select the Request Type';                
              } 

                return {
        'isValid':isValid,
        'message':message
    };
}

validateAcademicstudy(jsonObj){
let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;

if(typeof(json.ldata.asp_l_last_qualify) !== "undefined" && json.ldata.asp_l_last_qualify !== null){
    if(typeof(json.ldata.asp_l_gpa) !== "undefined" && json.ldata.asp_l_gpa !== null){
    if(typeof(json.ldata.asp_l_lastcertificate_award) !== "undefined" && json.ldata.asp_l_lastcertificate_award !== null){  
    if(typeof(json.ldata.asp_l_gpa_classification) !== "undefined" && json.ldata.asp_l_gpa_classification !== null){
    if(typeof(json.ldata.asp_l_place_of_award) !== "undefined" && json.ldata.asp_l_place_of_award !== null){ 
    if(typeof(json.ldata.asp_l_no_of_study_years) !== "undefined" && json.ldata.asp_l_no_of_study_years !== null){  
    if(typeof(json.ldata.asp_l_major_special) !== "undefined" && json.ldata.asp_l_major_special !== null){ 
    if(typeof(json.ldata.asp_l_sponsor) !== "undefined" && json.ldata.asp_l_sponsor !== null){ 
    if(typeof(json.ldata.asp_q_qualify_request) !== "undefined" && json.ldata.asp_q_qualify_request !== null){
    if(typeof(json.ldata.asp_q_country_sp) !== "undefined" && json.ldata.asp_q_country_sp !== null){
    if(typeof(json.ldata.asp_q_study_type) !== "undefined" && json.ldata.asp_q_study_type !== null){
    if(typeof(json.ldata.asp_q_college_university) !== "undefined" && json.ldata.asp_q_college_university !== null){
    if(typeof(json.ldata.asp_q_scholarship_duration) !== "undefined" && json.ldata.asp_q_scholarship_duration !== null){
    if(typeof(json.ldata.asp_q_duration_units) !== "undefined" && json.ldata.asp_q_duration_units !== null){
                  
                  isValid="true";
                  message='null';
              }else{
                isValid="false";
                message='Please Select the Duration Units';                
              }
               }else{
                isValid="false";
                message='Please Enter the Schlorship Duration';                
              }
               }else{
                isValid="false";
                message='Please Enter the College/University Name';                
              }
               }else{
                isValid="false";
                message='Please Select the Study Type';                
              }
               }else{
                isValid="false";
                message='Please Select the Country Study Place';                
              }
               }else{
                isValid="false";
                message='Please Select the Qualification in Request';                
              }
              }else{
                isValid="false";
                message='Please Select the Sponsor';                
              } 
              }else{
                isValid="false";
                message='Please Enter the Major/Specialization';                
              }
             } else{
                isValid="false";
                message='Please Enter the Number of Study Years';                
              } 
              } else{
                isValid="false";
                message='Please Enter the Place of Award';                
              } 
              } else{
                isValid="false";
                message='Please Select the Classification of GPA';                
              }  
              }  else{
                isValid="false";
                message='Please Select the Last Certificate Year of award';                
              }
              }else{
                isValid="false";
                message='Please Enter the GPA';                
              }
              }else{
                isValid="false";
                message='Please Select the Last Qualification';                
              } 

                return {
        'isValid':isValid,
        'message':message
    };
}



validateActingallowance(jsonObj){
let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;

if(typeof(json.ldata.aal_end_date) !== "undefined" && json.ldata.aal_end_date  !== null){
if(typeof(json.ldata.aal_from_date ) !== "undefined" && json.ldata.aal_from_date  !== null){
if(typeof(json.ldata.aal_reason ) !== "undefined" && json.ldata.aal_reason  !== null){

    // if(typeof(json.ldata.aal_position_job ) !== "undefined" && json.ldata.aal_position_job  !== null){

    // if(typeof(json.ldata.aal_section ) !== "undefined" && json.ldata.aal_section  !== null){  
    if(typeof(json.ldata.aal_new_position ) !== "undefined" && json.ldata.aal_new_position  !== null){

   isValid="true";
   message='null';
              }else{
                isValid="false";
                message='Please Enter the Vacant Position';                
              }
              //  }else{
              //   isValid="false";
              //   message='Please Enter the Section';                
              // }


              //  }else{
              //   isValid="false";
              //   message='Please Enter the Job';                
              // }
              
               }else{
                isValid="false";
                message='Please Enter the Reason';                
              }
              }else{
                isValid="false";
                message='Please Enter the Start Date';                
              }
              }else{
                isValid="false";
                message='Please Enter the End Date';                
              }


return {
        'isValid':isValid,
        'message':message
    };
}



validateBusinessRequest(jsonObj){
let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;

// if(typeof(json.ldata.bcr_designation_in_arabic ) !== "undefined" && json.ldata.bcr_designation_in_arabic  !== null){
    if(typeof(json.ldata.bcr_direct_number  ) !== "undefined" && json.ldata.bcr_direct_number   !== null){
    if(typeof(json.ldata.bcr_mobile_number ) !== "undefined" && json.ldata.bcr_mobile_number  !== null){  
    

              isValid="true";
              message='null';
               }else{
                isValid="false";
                message='Please Enter the Mobile Number';                
              }
               }else{
                isValid="false";
                message='Please Enter the Direct Number';                
              }
              //  }else{
              //   isValid="false";
              //   message='Please Enter the Designation in Arabic';                
              // }


return {
        'isValid':isValid,
        'message':message
    };
}
// *****************
    /**
     *
     * @param {String} arg1
     * @return {String}
     */
    getSubmitInstance(p_APPR_PROCESS, p_TRX_ID, p_USER_ID) {

      let callSubmitPackage="NO";

      let processDefinitionId=null;
      let applicationName=null;
      let processName=null;
      let applicationVersion=null;

      if(window.location.href === "https://fa-*******.oraclecloud.com"){
         console.log("---PROD Approver--");
        processDefinitionId="1223";
        applicationName="SelfService";
        processName="SelfServiceProcess";
        applicationVersion="1.2";

       }else{
        console.log("---TEST Approver--");
        processDefinitionId="868593d9-2ddc-11ee-ac65-36b67b419c5a";
        applicationName="SelfService";
        processName="SelfServiceProcess";
        applicationVersion="1.2";
      }   

      return {
          'processDefinitionId':processDefinitionId,
          'callSubmitPackage':callSubmitPackage,
          'applicationName':applicationName,
          'processName':processName,
          'applicationVersion':applicationVersion
      };


    }
// validation
checkValiDation111(pattendfilename,pprefilename,passportno,idcardno)
    {
      let isValid="false";
      let message=null;
      let lattendfilename=null;
	  let lpprefilename=null;
 
          if(passportno=='Yes' && (pprefilename!=undefined || pprefilename!=null)){
            if(idcardno=='Yes' && (pattendfilename!=undefined || pattendfilename!=null))
            {
             
              isValid="true";
              message=''; 
              console.log("result1==>"+pattendfilename);
            }
            else{
              isValid="false";
              message='ID Card Attachment is mandatory'; 
               console.log("result1==>"+pattendfilename);
            }
          
          }else{
             isValid="false";
              message='Passport Attachment is mandatory '; 
              console.log("result2==>"+pprefilename);
          }
        return {
        'isValid':isValid,
        'message':message
        };

    };


// 


checkValiDation(passportno, pattendfilename, pprefilename, idcardno) {
   let isValid = "true";
  let message = null;
  let lattendfilename = null;
  let lpprefilename = null;

  if (passportno === 'Yes' && (pprefilename === undefined || pprefilename === null)) {
    isValid = "false";
    message = 'Passport Attachment is mandatory';
  }

  if (idcardno === 'Yes' && (pattendfilename === undefined || pattendfilename === null)) {
    isValid = "false";
    message = 'ID Card Attachment is mandatory';
  }

  return {
    isValid: isValid,
    message: message
  };
};
//oncall validation


 validateAndTransformDatesAndHours (Fromdate, Enddate, Fromhours, Tohours){
  // Validate and transform Fromhours and Tohours to integers
  const fromHoursInt = parseInt(Fromhours);
  const toHoursInt = parseInt(Tohours);

  // Check if Fromdate and Enddate are the same
  if (Fromdate === Enddate) {
    if (fromHoursInt >= toHoursInt) {
      return { message: "Time To should be greater than the Time From",
      fromHoursInt: fromHoursInt,
      toHoursInt: toHoursInt };
    }
  }

  // If all validations pass, return a success message or the transformed values
  return { 
    message: "Validation successful",
    fromHoursInt: fromHoursInt,
    toHoursInt: toHoursInt
  };
}


// on call
validateFiledoncallduty(status,userGroup,taskId,requesttype) {

	    var fin_bind_access="false";
      
      console.log("access==status==>"+status);
      console.log("access==userGroup==>"+userGroup);
      console.log("access==taskId==>"+taskId);
     //console.log("access==apprlevel==>"+apprlevel);
    //  console.log("access==reqstatus==>"+reqstatus);
     


     if((status=== "Pending" || status=== "Approver More Info" || status=== "Employee More Info") && requesttype==="ON_CALL_DUTY" && taskId!=null && userGroup ==="COMPENSATION_TEAM"){
            console.log("access==5==>");
	          fin_bind_access="false";
            
      }
      else{
            console.log("access==6==>");
	          fin_bind_access="true";
            
      } 
      

    
    console.log("fin_bind==>access==>"+fin_bind_access);


      return {
              
              'fin_bind_access':fin_bind_access
            };
  };

  

// 
validateempFiled(status,taskId) {

	    var fin_bind_access="false";
      var emp_disable_access="false";
      console.log("access==status==>"+status);
      console.log("access==taskId==>"+taskId);
    


     if((status=== "Draft" || status === "Return for Correction") && taskId===undefined){
            console.log("access==5==>");
	          fin_bind_access="false";
      }
      else if(status=== "Approved" && taskId===undefined){
            console.log("access==5==>");
	          fin_bind_access="true";
      }else{
            console.log("access==6==>");
	          fin_bind_access="true";
      } 
      

    
    console.log("employee==>access==>"+fin_bind_access);


      return {
              
              'fin_bind_access':fin_bind_access
            };
  };

    /**
     *
     * @param {String} arg1
     * @return {String}
     */
    validateTapcChildNew(jsonObj) {
    let obj = JSON.stringify(jsonObj);
    let json= JSON.parse(obj);
    let isValid="false";
    let message=null;
    if(typeof(json.ldata.tapc_visitor_name) !== "undefined" && json.ldata.tapc_visitor_name !== null){
       if(typeof(json.ldata.tapc_id_number) !== "undefined" && json.ldata.tapc_id_number !== null){
          if(typeof(json.ldata.tapc_job_desigination) !== "undefined" && json.ldata.tapc_job_desigination !== null){
                  isValid="true";
                  message='null';
          } else{
            isValid="false";
            message='Please Enter the Job Designation';                     
          } 
       }else{
          isValid="false";
          message='Please Enter Id Number';         
       } 
    }else{
        isValid="false";
        message='Please Enter the Visitor Name';
    }

    return {
        'isValid':isValid,
        'message':message
    };
    
    }
 }


//report download

  return PageModule;
});
