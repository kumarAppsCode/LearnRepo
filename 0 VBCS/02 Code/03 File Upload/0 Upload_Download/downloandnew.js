define(['ojs/ojpagingdataproviderview','ojs/ojarraydataprovider'], 
function(PagingDataProviderView,ArrayDataProvider) {
  'use strict';

  class PageModule {
  
  // genericFileURL() {
  //   return require.toUrl('resources/files/Worksheet in OWWSC Time and Labor - CRP 1 (1) (4).xls');
  // };
      pagingSearch(array) {
      var data = new PagingDataProviderView(new ArrayDataProvider(
      array, {
        idAttribute: 'file_upload_id'
        }));
      return data;
    };


  processFile(fileSet) {
    let reader = new FileReader();
    return new Promise(function(resolve, reject) {
        let reader = new FileReader();
        reader.onloadend = function(e) {
           let data = e.target.result;
           let workbook = XLSX.read(data, {type: 'binary'});
           let first_worksheet = workbook.Sheets[workbook.SheetNames[0]];
           let jsonArr = XLSX.utils.sheet_to_json(first_worksheet, {header:1});          
           resolve(jsonArr);
        };
       reader.readAsBinaryString(fileSet[0]); 
     });
  };


  //     processFiles(fileSet) {

  //      $('.progress').show();

  //   var reader = new FileReader();

  //   return new Promise(function(resolve, reject) {

  //       var reader = new FileReader();

   

  //       reader.onloadend = function(e) {

  //          var data = e.target.result;

  //          var workbook = XLSX.read(data, {type: 'binary'});

  //          var first_worksheet = workbook.Sheets[workbook.SheetNames[0]];

  //          var jsonArr = XLSX.utils.sheet_to_json(first_worksheet, {header:1,raw:false});

  //          console.log(jsonArr);

  //          resolve(jsonArr);

  //       };

  //       reader.readAsBinaryString(fileSet[0]);

  //    });

  // };

  
    populateData(jsonArr,attachment_id) {
     var parts = [];
     var final = {};
     var headerArray= [
      //  'year',
      //  'month',
       'level',
      //  'person_id',
       'employee_number',
       'employee_name',
      //  'supervisor_id',
       'supervisor_number',
       'supervisor_name',
       'year',
       'month',
       'day01',
       'day02',
       'day03',
       'day04',
       'day05',
       'day06',
       'day07',
       'day08',
       'day09',
       'day10',
       'day11',
       'day12',
       'day13',
       'day14',
       'day15',
       'day16',
       'day17',
       'day18',
       'day19',
       'day20',
       'day21',
       'day22',
       'day23',
       'day24',
       'day25',
       'day26',
       'day27',
       'day28',
       'day29',
       'day30',
       'day31' 
             
       ];     
    
        for (var j = 1; j < jsonArr.length; j++){
          var obj = {};
          var partObject ={};
          for (var i = 0; i < jsonArr[0].length; i++) {
            var objName = headerArray[i];
            var objValue = jsonArr[j][i];    
            obj[objName] = objValue;
            obj['attachment_id'] = attachment_id;
          }
          parts.push(obj);
      }

      final["parts"] = parts;
      console.log("attachment_id"+parts);

     return final;
  };


  





    /**
     *
     * @param {String} arg1
     * @return {String}
     */
    validateFiletypeJs(fileType) {
    
    if(
      fileType==="application/vnd.ms-excel"  ||
      fileType==="application/kset"  ||
      fileType==="text/csv"
    ){
      return true;
    }else{
      return true;
    }
    
    
    }
   }
  return PageModule;
});
