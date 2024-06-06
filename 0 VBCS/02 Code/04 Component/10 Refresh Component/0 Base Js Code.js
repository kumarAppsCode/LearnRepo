define(['ojs/ojpagingdataproviderview','ojs/ojarraydataprovider'], 
function(PagingDataProviderView,ArrayDataProvider) {
  'use strict';

  class PageModule {

       pagingSearch(array) {
      let data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'request_id'
        }));
      return data;
    };
//---Refresh Start 
    constructor(context) {
      this.eventHelper = context.getEventHelper();
      this.promiseResolver = {};
    }
    // refresh-content function to use in HTML
    getRefreshFunction() {
      return this.checkForUpdates.bind(this);
    }
    // the function to raise a custom event and return a promise
    checkForUpdates() {
      let myPromise = new Promise(function (resolve, reject) {
        this.promiseResolver.resolveHandler = resolve;
      });
      // raise a check for refresh event and refresh the data set
      // from the action chain associated with the event
      this.eventHelper.fireCustomEvent("customRefreshContentsEvent");
      return myPromise;
    }

    // the function to call to resolve the promise after data refresh
    concludeRefresher() {
      // data refreshed, resolve the promise now
      // timeout is a dummy delay so the refresh does on
      // complete immediately
      setTimeout(() => {
        this.promiseResolver.resolveHandler();
      }, 2000);
    }
//---Refresh End 

  }
 return PageModule;
});
