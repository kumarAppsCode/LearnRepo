/*
  Copyright (c) 2018, Oracle and/or its affiliates.
  The Universal Permissive License (UPL), Version 1.0
*/
define([], function () {
  'use strict';

  var AppModule = function AppModule() {};


// 
AppModule.prototype.isFormValid = function(form) {
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
AppModule.prototype.validateDate = function(dateValue) {
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

// Remove square []
AppModule.prototype.removeSquareBracket = function(jsonObj) {
      // var dateregex= /^[0-9]{4}[\-][0-9]{2}[\-][0-9]{2}$/g;
      var squarebracket= /[\[\]']+/g;
      let objAsString = JSON.stringify(jsonObj);
      // let stringifiedString = objAsString.replace(/[\[\]']+/g, "");
      let jsonResult = objAsString.replace(squarebracket, "");
      // console.log("Stage1===>>"+jsonResult);
      return jsonResult;
    };

// 
AppModule.prototype.toDayDate = function() {
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    today = yyyy+'-'+mm+'-'+dd+'T00:00:00Z'; 
    // today = yyyy+'-'+mm+'-'+dd; 
    return today;
  };


// Remove Space
  AppModule.prototype.removeSpace = function (value) {
    // console.log("login value==>"+value);
    // // var data=value.replace(/ /g, "");
    // var data1=value.replaceAll(/\s/g,'');
    // // console.log("data1===>"+data1);
    // var data=value.replace(/[^a-zA-Z0-9]/g, '');
    // // console.log("data===>"+data);
    // return data;
    return value;
  };


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





  return AppModule;
});
