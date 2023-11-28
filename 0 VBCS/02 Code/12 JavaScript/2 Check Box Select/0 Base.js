define([], () => {
  'use strict';

  class PageModule {
    getRowDataFromTable() {
      var index = 0;
      var result = [];
      var table = document.getElementById("emptable");
       // search only in first 10000 rows:
      while (index < 10000) {
        var row = table.getDataForVisibleRow(index);
        if(row!=null){
        
          result.push(row.data.id);
        }else{
          break;
        }
       
        index++;
      }
      return result;
    };

    getSelectedKeys(selected) {
      var result = [];
      var keys = [];
      if (selected.row.isAddAll()) {
        const iterator = selected.row.deletedValues();
        iterator.forEach(function (key) {
            keys.push(key);
        });
        var data = this.getRowDataFromTable();
        result = data.filter(function(obj) {
          return !keys.some(function(obj2) {
              return obj == obj2;
          });
      });
       
      }
      else {
        const row = selected.row;
        if (row.values().size > 0) {
          row.values().forEach(function (key) {
            result.push(key);
          });
        }
      }
      return result;
    };
  createDeleteBatchPayload(array) {
    var payloads = [];
    var uniqueId = (new Date().getTime());
    for(var i=0;i<array.length;i++){
         payloads.push(
          {
            "id": i,
            "path": "/Employee/"+array[i],
            "operation": "delete"
          }
        );
    }
   
    return {
      parts: payloads
    };
  };

resetSelection(tableId){
  document.getElementById(tableId).selection=[];
}
  }
  
  return PageModule;
});
