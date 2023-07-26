define(['ojs/ojpagingdataproviderview','ojs/ojarraydataprovider'], function(PagingDataProviderView,ArrayDataProvider) {
  'use strict';

  class PageModule {
  }

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

  return PageModule;
});
