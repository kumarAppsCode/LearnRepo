define(['ojs/ojpagingdataproviderview','ojs/ojarraydataprovider'], 
function(PagingDataProviderView,ArrayDataProvider) {
  'use strict';
  class PageModule {
  
  // sysdatefunction
  
   pageSysDates() {
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    today = yyyy+'-'+mm+'-'+dd; 
    return today;
  };
    /**
     *
     * @param {String} arg1
     * @return {String}
     */
   
   // function for adp key(used as a primary key)
    pagingLine(array) {
      var data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'action_history_id'
        }));
      return data;
    };
// 
getSubmitInstance(modulename) {

      let callSubmitPackage="NO";

     
      let applicationName=null;
      let processName=null;
      let applicationVersion=null;

      if(modulename==='TRAVEL_REQUEST'){
         console.log("---TRAVEL_REQUEST--");
       applicationName="TravelRequest";
        processName="TravelProcess";
        applicationVersion="1.1";
}
        else if(modulename==='SELF_SERVICE'){
         console.log("---SELF_SERVICE--");
       applicationName="SelfService";
        processName="SelfServiceProcess";
        applicationVersion="1.3";
 }
else if(modulename==='LEARNING_REQUEST'){
         console.log("---LEARNING_REQUEST--");
       applicationName="LearningRequest";
        processName="LearningProcess";
        applicationVersion="1.1";
}
else if(modulename==='SITE_OVERTIME_REQUEST'){
         console.log("---SITE_OVERTIME_REQUESTr--");
       applicationName="SiteOvertimeRequest";
        processName="OverTimeProcess";
        applicationVersion="1.3";
}
else if(modulename==='OVER_TIME_REQUEST'){
         console.log("---OVER_TIME_REQUEST--");
       applicationName="OverTimeRequest";
        processName="OverTimeProcess";
        applicationVersion="1.1";
}
       else {
         applicationName="ABC";
        processName="ABC";
        applicationVersion="1.1";
      }   

      return {

          'applicationName':applicationName,
          'processName':processName,
          'applicationVersion':applicationVersion
      };


    }



  }
  return PageModule;
});

