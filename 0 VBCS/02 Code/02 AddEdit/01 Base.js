define(['ojs/ojpagingdataproviderview','ojs/ojarraydataprovider'], function(PagingDataProviderView,ArrayDataProvider) {
  'use strict';


  var PageModule = function PageModule() {};



   PageModule.prototype.submitPayload=function(hdrId){
      
      let result="{\"hdrId\":\""+hdrId+"\",\"taskId\":\"\"}";
      
      // console.log("result==>"+result);
      
      return result;
    };

    // 	 PageModule.prototype.submitPayload = function(hdrId) {
    //   var data = new PagingDataProviderView(new ArrayDataProvider(
    //   hdrId, {
    //     idAttribute: "{\"io_payment_hdr_id\":\""+hdrId+"\",\"taskId\":\"\"}"
    //     }));
    //   return data;
    // };

  PageModule.prototype.sysDates = function() {
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    today = yyyy+'-'+mm+'-'+dd; 
    return today;
  };


//  Search lookup value 
    PageModule.prototype.pagingline = function(array) {
      var data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'io_payment_dtl_id'
        }));
      return data;
    };


        PageModule.prototype.pagingApprovalHis = function(array) {
      var data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'action_history_id'
        }));
      return data;
    };


  PageModule.prototype.pagingSearch = function(array) {
      var data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'io_payment_hdr_id'
        }));
      return data;
    };

       PageModule.prototype.pagingAttachment = function(array) {
      var data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'document_id'
        }));
      return data;
    };

   PageModule.prototype.pagingAttachmentExp = function(array) {
      var data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'document_id'
        }));
      return data;
    };


  PageModule.prototype.pagingSecureAttachmentExp = function(array) {
      var data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'document_id'
        }));
      return data;
    };

  PageModule.prototype.attachmentcount = function (array) {
    // console.log("array==>" + JSON.stringify(array));
    var expenseHdrCount =0;
    var expenseClaimHdrCount =0;
    var secureHdrCount=0;

        for (var i = 0; i < array.length; i++) {
            if(array[i].appl_code==="IO_PAYMENT_HEADER"){
              expenseHdrCount=array[i].lcount;
            }
            if(array[i].appl_code==="IO_INVOICE_DETAIL"){
              expenseClaimHdrCount=array[i].lcount;
            }
            if(array[i].appl_code==="IO_PAYMENT_SECURE"){
              secureHdrCount=array[i].lcount;
            }
        }

    return {
          'expenseHdrCount'       :expenseHdrCount,
          'expenseClaimHdrCount'  :expenseClaimHdrCount,
          'secureHdrCount':secureHdrCount
    };

  };


   

PageModule.prototype.checkingreassign=function(person_id,comment)
    {
      let isValid="false";
      let message=null;
          if(typeof(person_id)!== "undefined" && person_id!== null){
                if(typeof(comment)!="undefined" && comment!== null){
                  isValid="true";
                  message=''; 
                }else{
                  isValid="false";
                  message='Please Enter comments'; 
                }
          }else{
             isValid="false";
              message='Please Select the employee '; 
          }

        return {
        'isValid':isValid,
        'message':message
        };

    };

PageModule.prototype.downloadFileFromBase64 = function (base64String,name,type) {
    var applicationType = "data:"+type+";base64,";
    var finalContent = applicationType+base64String;
    const downloadLink = document.createElement('a');
    document.body.appendChild(downloadLink);
    downloadLink.href = finalContent;
    downloadLink.download =name;
    downloadLink.click();
  };



  PageModule.prototype.minDate = function() {
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    today = yyyy+'-'+mm+'-'+dd;

    return today;
  };

// 04/01/2022


    PageModule.prototype.getTimeHrs = function (ltime) {
      let lvalue = ltime.substring(1, 3);
      return lvalue;
  };

PageModule.prototype.getDailyRate = function (currency, amount, conversionDate) {
    let status="N";
      if(typeof(currency) !== "undefined" && currency !== null){
          if(typeof(conversionDate) !== "undefined" && conversionDate !== null && conversionDate!=0){
              if(typeof(amount) !== "undefined" && amount !== null && amount!=0){
                status="Y";
              }else{
                status="N";
              }
          }else{
            status="N";          
          }  
      }else{
        status="N";          
      }

    return status;
};


PageModule.prototype.calculateDailyRate = function (rateValue, enteramount) {

    let finRateValue=0;
    let finAmount=0;
    let message="";
    let status="N";

      console.log("rateValue==>"+rateValue);
      console.log("enteramount==>"+enteramount);

    if(typeof(rateValue) !== "undefined" && rateValue !== null & rateValue !=0 && 
       typeof(enteramount) !== "undefined" && enteramount !== null & enteramount !=0){

         let resultAmount= rateValue*enteramount;

        console.log("resultAmount==>"+resultAmount);

        finRateValue=rateValue;
        finAmount=resultAmount;
        message="Calculated Amount null";
        status="N";
    }else{
        finRateValue=0;
        finAmount=0;
        message="Calculated Amount null";
        status="N";
    }

    return {
        'finRateValue':finRateValue,
        'finAmount':finAmount,
        'message':message,
        'status':status
    };

  };


    PageModule.prototype.getTimeMin = function (ltime) {
      let lvalue = ltime.substring(4, 6);
      return lvalue;
  };

  PageModule.prototype.removeTimeStamp = function(dateValue) {
    let dateLength=dateValue.length;
        if(dateLength==10){
          dateValue=dateValue;
        }else{
          dateValue=dateValue.substring(0, 10);
        }
        return dateValue;
};

  PageModule.prototype.getDepartmentId = function(depId) {
    var ldepart=0;
    console.log("=>ORG==>DEP==>"+depId);
    if(depId!=null && depId!=undefined){
      ldepart=depId;
    }else{
      ldepart=0;
    } 
    console.log("=>DEP==>"+ldepart)
    return ldepart;
  };

 PageModule.prototype.validateFiled1 = function (request_status, taskId, user_group) {
    var flag=false;
    
      console.log("user==>"+user_group);
      console.log("status==>"+request_status);
      console.log("taskId==>"+taskId);

       if(request_status === 'Draft' || request_status === 'Reject'){
            console.log("1==>");
            flag=false;
       }else{
            if(user_group === 'IO_PAYMENT_REVIEWER'){
                 if (taskId!=undefined && request_status === 'Pending'){
                      flag=false;
                 }else{
                      console.log("3==>");
                      flag=true;
                 }
            }else{
                  flag=true;
            }
       }
    console.log("Disable==>"+flag);
    return flag;
  };



  PageModule.prototype.validateFiled = function(request_status,taskId,user_group,appType){
      var fullaccess="false";
	    var lineaccess="false";
      var secureaccess="false";
      // console.log("==0==>");
      // console.log("Acc==user==>"+user_group);
      // console.log("Acc==status==>"+request_status);
      // console.log("Acc==taskId==>"+taskId);
      // console.log("Acc==appType==>"+appType);

    if(request_status === "Draft" || request_status === "Reject"){
            fullaccess="false";
            lineaccess="false"; 
            secureaccess="false";
			//  console.log("Acc==1==>"+request_status);
      //  console.log("Acc==1==>"+secureaccess);
      
        }else if(request_status === "Approved" && appType === "IT"){
            fullaccess="true";
            lineaccess="true"; 
            secureaccess="false";
			// console.log("Acc==2==>"+request_status);
      // console.log("Acc==2==>"+appType);
     
        } 
      else if(request_status === "Approved" && appType === "EMP"){
                  fullaccess="true";
                  lineaccess="true"; 
                  secureaccess="true";
            // console.log("Acc==3==>"+request_status);
            // console.log("Acc==3==>"+appType);
            
              } 
       else if(request_status === "Pending" && appType === "EMP"){
            fullaccess="true";
            lineaccess="true"; 
            secureaccess="true";
      // console.log("datavalidation===>"+datavalidation);
			// console.log("Acc==4==>"+request_status);
      // console.log("Acc==4==>"+appType);
      // console.log("Acc==4==>"+taskId);
        } 
        else if(request_status === "Pending" && appType === "IT" && taskId!=null && user_group ==="IO_PAYMENT_INVOICE"){
            fullaccess="true";
            lineaccess="false"; 
            secureaccess="true";
            // console.log("Acc==6==>"+request_status);
            // console.log("Acc==6==>"+appType);
            // console.log("Acc==6==>"+taskId);
            // console.log("Acc==6==>"+user_group);
            // console.log("Acc==6==>"+fullaccess);
        }     
 else if(request_status === "Pending" && appType === "IT" && 
 taskId!=null && 
 (user_group==="IO_PAYMENT_REVIEWER" || 
  user_group==="IO_REVIEWER_QIA_HR_DEPT2" || 
  user_group==="IO_PAYMENT_SIN_APPROVER1" || 
  user_group==="IO_PAYMENT_USA_APPROVER1" || 
  user_group==="IO_PAYMENT_USA_APPROVER2" || 
  user_group==="IO_REVIEWER_FINANCE_DEPT" ||
  user_group==="IO_REVIEWER_QIA_TAX_DEPT" || 
  user_group==="IO_REVIEWER_QIA_LEGAL_DEPT" || 
  user_group==="IO_REVIEWER_IT_DEPT" || 
  user_group==="IO_REVIEWER_QIA_HR_DEPT" || 
  user_group==="IO_REVIEWER_QIA_ADMIN_DEPT" ||
  user_group==="IO_PAYMENT_UNDER_PROCESS" )){
   
          fullaccess="false";
            lineaccess="false"; 
            secureaccess="false";
			// console.log("Acc==5==>"+request_status);
      // console.log("Acc==5==>"+appType);
      // console.log("Acc==5==>"+taskId);
      // console.log("Acc==5==>"+user_group);
      // console.log("Acc==5==>"+secureaccess);
      // console.log("Acc==5==>"+lineaccess);
      // console.log("datavalidation===>"+datavalidation);
        
 }
		 
  else if(request_status === "Pending" && appType === "IT" && taskId!=null &&  (user_group==="IO_PAYMENT_APPROVER" || user_group==="FINAL_IO_PAYMENT_GROUP")){
          fullaccess="true";
            lineaccess="true"; 
            secureaccess="false";
			// console.log("Acc==7==>"+request_status);
      // console.log("Acc==7==>"+appType);
      // console.log("Acc==7==>"+taskId);
      // console.log("Acc==7==>"+user_group);
  }
else{
    fullaccess="true";
    lineaccess="true"; 
    secureaccess="true";
  } 
  
    // console.log("Acc==fullaccess"+fullaccess);
    // console.log("Acc==lineaccess"+lineaccess);
    // console.log("Acc==secureaccess"+secureaccess);


           			return {
              'fullaccess':fullaccess,
              'lineaccess':lineaccess,
              'secureaccess':secureaccess
                 };
};
//  PageModule.prototype.submitPayload(hdrId){
//       let result="{\"io_payment_hdr_id\":\""+hdrId+"\",\"taskId\":\"\"}";
//       return result;
//     };
 
  /**
   *
   * @param {String} arg1
   * @return {String}
   */
 
 /*PageModule.prototype.checkBoxConverstion = function (arg1) {
    var result=null;
      // console.log("log====>"+arg1);
      if(arg1===true){
        // console.log("log Stage 1====>"+arg1);
        result="Y";
      } else{
      // console.log("log Stage 2====>"+arg1);
        result="N";
      } 
    return result;
    };  */

 PageModule.prototype.getApplicationApprover=function(person_number, person_email_id){
      console.log("log==>"+window.location.host)
      if(window.location.href === "https://******.ocp.oraclecloud.com"){
          console.log("---PROD Approver--");
          return person_email_id;
      }else{
        console.log("---TEST Approver--");
          return person_number;
      }

    };

  return PageModule;
});
