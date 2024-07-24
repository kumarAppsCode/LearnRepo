define(['ojs/ojpagingdataproviderview','ojs/ojarraydataprovider'], 
function(PagingDataProviderView,ArrayDataProvider) {
  'use strict';

  class PageModule {
      pagingSearch(array) {
      var data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'file_upload_id'
        }));
      return data;
    };

    downloadFileFromBase64(base64String,name,type) 
    {

    var applicationType = "data:"+type+";base64,";

    var finalContent = applicationType+base64String;

    const downloadLink = document.createElement('a');

    document.body.appendChild(downloadLink);

    downloadLink.href = finalContent;

    downloadLink.download =name;

    downloadLink.click();
    

  

  };




  }
  
  return PageModule;
});
