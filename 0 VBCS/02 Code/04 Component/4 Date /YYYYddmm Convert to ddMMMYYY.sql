/* Copyright (c) 2023, Oracle and/or its affiliates */

define([], function() {
  'use strict';

  class PageModule {
  }
PageModule.prototype.convertDateToCustomFormat =function(dateString) {
    // Define month names
    const months = [
        "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
        "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
    ];
    
    // Split the date string into parts
    const parts = dateString.split('-');
    const year = parts[0];
    const month = months[parseInt(parts[1], 10) - 1];
    const day = parts[2];
    
    // Create a new date string in the format DD/MON/YYYY
    const customDate = `${day}/${month}/${year}`;
    
    return customDate;
}
  return PageModule;
});
