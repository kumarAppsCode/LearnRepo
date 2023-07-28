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
    PageModule.prototype.pageLine = function(array) {
      var data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'kare_detail_id'
        }));0
      return data;
    };

  PageModule.prototype.downloadExcel = function (data) {
    var createXLSLFormatObj = [];
    var xlsHeader = [
                      "AY",
                      "School",
                      "Category",
                      "SKU",
                      "SKU Desc",
                      "Required (SZ)",
                      "Kare Stock (SZ)",
                      "School Shipped qty (SZ)",
                      "Open Kare PO (SZ)",
                      "Planned Procurement (SZ)",
                      "To be procured (SZ)",
                      "Required (WZ)",
                      "Kare Stock (WZ)",
                      "School shipped qty (WZ)",
                      "Open Kare PO (WZ)",
                      "Planned Procurement (WZ)",
                      "To be procured (WZ)",
                      "To be procured (Total)",
                      "Rate",
                      "GST",
                      "Value"
    ];
    createXLSLFormatObj.push(xlsHeader);
    $.each(data, function (index, value) {
      var innerRowData = [];
      innerRowData.push(value.ay);
      innerRowData.push(value.school);
      innerRowData.push(value.category_info);
      innerRowData.push(value.sku_details);
      innerRowData.push(value.sku_desc);
      innerRowData.push(value.required_sz);
      innerRowData.push(value.kare_stock_sz);
      innerRowData.push(value.school_shipped_qty_sz);
      innerRowData.push(value.open_kare_po_sz);
      innerRowData.push(value.planned_procurement_sz);
      innerRowData.push(value.to_be_procured_sz);
      innerRowData.push(value.required_wz);
      innerRowData.push(value.kare_stock_wz);
      innerRowData.push(value.school_shipped_qty_wz);
      innerRowData.push(value.open_kare_po_wz);
      innerRowData.push(value.planned_procurement_wz);
      innerRowData.push(value.to_be_procured_wz);
      innerRowData.push(value.to_be_procured_total);
      innerRowData.push(value.rate);
      innerRowData.push(value.gst);
      innerRowData.push(value.value_amt);
     
      createXLSLFormatObj.push(innerRowData);
      
    });

    var filename = "Download.xlsx";
    /* Sheet Name */
    var ws_name = "Download";
    var wb = XLSX.utils.book_new(),
      ws = XLSX.utils.aoa_to_sheet(createXLSLFormatObj);
    /* Add worksheet to workbook */
    XLSX.utils.book_append_sheet(wb, ws, ws_name);
    /* Write workbook and Download */
    XLSX.writeFile(wb, filename);
  };

  PageModule.prototype.processFile = function (fileSet) {
    var reader = new FileReader();
    return new Promise(function(resolve, reject) {
        var reader = new FileReader();
        reader.onloadend = function(e) {
           var data = e.target.result;
           var workbook = XLSX.read(data, {type: 'binary'});
           var first_worksheet = workbook.Sheets[workbook.SheetNames[0]];
           var jsonArr = XLSX.utils.sheet_to_json(first_worksheet, {header:1});          
           resolve(jsonArr);
        };
       reader.readAsBinaryString(fileSet[0]); 
     });
  };

  PageModule.prototype.populateData = function (jsonArr, loginUser) {
     var parts = [];
     var final = {};
     var headerArray= [
       'ay',
       'school',
       'category_info',
       'sku_details',
       'sku_desc',
       'required_sz',
       'kare_stock_sz',
       'school_shipped_qty_sz',
       'open_kare_po_sz',
       'planned_procurement_sz',
       'required_wz',
       'kare_stock_wz',
       'school_shipped_qty_wz',
       'open_kare_po_wz',
       'planned_procurement_wz',
       'to_be_procured_wz'
       ];     
    
        for (var j = 1; j < jsonArr.length; j++){
          var obj = {};
          var partObject ={};
          for (var i = 0; i < jsonArr[0].length; i++) {
            var objName = headerArray[i];
            var objValue = jsonArr[j][i];    
            obj[objName] = objValue;
            obj['created_by'] = loginUser;
            
          }
          parts.push(obj);
      }

      console.log(parts);
      final["parts"] = parts;

     return final;
  };








  return PageModule;
});
