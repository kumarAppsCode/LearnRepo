define([], () => {
  'use strict';

  class AppModule {


// 
isFormValid(form) {
var tracker = document.getElementById(form); 
if (tracker.valid === "valid") {
  return true;
} else {
tracker.showMessages();
tracker.focusOn("@firstInvalidShown");
return false;
}
};

// Validate Date
validateDate(dateValue) {
  let dateLength=dateValue.length;
        // window.alert(dateLength);
        // console.log('Date Length==>>'+dateLength);
        if(dateLength==10){
          dateValue=dateValue+'T00:00:00Z';
          console.log('Date Length 10==>>'+dateValue);
        }else{
          dateValue=dateValue;
          console.log('Date Length 10==>>'+dateValue);
        }
        return dateValue;
};


  removeSpace(value) {
    // // var data=value.replace(/ /g, "");
    // var data1=value.replaceAll(/\s/g,'');
    // // console.log("data1===>"+data1);
    // var data=value.replace(/[^a-zA-Z0-9]/g, '');
    // // console.log("data===>"+data);
    // return data;
    return value;
  };


  }
  
  return AppModule;
});

// {{$application.functions.isFormValid("CreateForm")}}
//  <oj-validation-group id="CreateForm">
//  <div class="oj-flex">
// <oj-form-layout  label-edge="start" max-columns="2" class="oj-flex-item oj-sm-12 oj-md-12">
//   <oj-label for="oj-input-text--1072052825-1" class="oj-flex-item oj-sm-12 oj-md-2">UserName</oj-label>
//   <oj-input-text id="oj-input-text--1072052825-1" class="oj-flex-item oj-sm-12 oj-md-4" required="true"></oj-input-text>
//   <oj-label for="oj-input-number--1072052825-1" class="oj-flex-item oj-sm-12 oj-md-4">Mobile No</oj-label>
//   <oj-input-number id="oj-input-number--1072052825-1" class="oj-flex-item oj-sm-12 oj-md-8" required="true"></oj-input-number>
//   <oj-input-date label-hint="StartDate" required="true"></oj-input-date>
// </oj-form-layout>
//  </div>
//   </oj-validation-group>

