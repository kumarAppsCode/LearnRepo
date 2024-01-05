define(['ojs/ojpagingdataproviderview','ojs/ojarraydataprovider'], 
function(PagingDataProviderView,ArrayDataProvider) {
  'use strict';
  var PageModule = function PageModule() {};
// Search
    PageModule.prototype.paginghdrdata = function(array) {
      var data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'lookup_type_id'
        }));
      return data;
    };
  return PageModule;
});
