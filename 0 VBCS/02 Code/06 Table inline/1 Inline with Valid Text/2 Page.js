define([], () => {
  'use strict';

  class PageModule {

    /**
     *
     * @param {String} arg1
     * @return {String}
     */
    generateJsonObj(array, loginuser, sysdate) {
      //console.log("XX2----1>" + JSON.stringify(array));
      var payload = {};
      var final = {};
      let isValid = "true";
      let message = null;
      let ldata = 0;

      for (var i = 0; i < array.length; i++) {
         array[i].lookup_value_code = document.getElementById('lookup_value_code' + i) == null ? null : document.getElementById('lookup_value_code' + i).value;
         array[i].lookup_value_name = document.getElementById('lookup_value_name' + i) == null ? null : document.getElementById('lookup_value_name' + i).value;
         array[i].created_by = document.getElementById('created_by' + i) == null ? null : document.getElementById('created_by' + i).value;
         array[i].lookup_type_id = 1;
         array[i].created_by = document.getElementById('created_by' + i) == null ? null : document.getElementById('created_by' + i).value;
         array[i].creation_date = document.getElementById('creation_date' + i) == null ? null : document.getElementById('creation_date' + i).value;
         array[i].last_updated_by = loginuser;
         array[i].last_update_date = sysdate;
         array[i].last_update_login = loginuser;

        ldata = ldata + 1;
      }

      payload.item = array; 
      final["items"]=array;
      console.log("ldata==>list count==>" + ldata);
      console.log("XX5----1>payload.item==>3" + JSON.stringify(payload.item));
      console.log("Final Items" + JSON.stringify(final));


      return {
        'isValid': isValid,
        'message': message,
        'payload': payload,
        'final'  : final
      };
      
    }
  
  
  
      getSysdate() {
      return new Date().toISOString();
    };
  
  
  }
  



  return PageModule;
});
