define([], () => {
  'use strict';

  class PageModule {

      getSysdate() {
      return new Date().toISOString();
    };

    /**
     *
     * @param {String} arg1
     * @return {String}
     */
    generateJsonObj(array,loginuser) {
      // console.log("Json----1>" + JSON.stringify(array));
      // let payload = {};
      // let final = {};
      let isValid = "true";
      let message = null;
      // let ldata = 0;

      // for (var i = 0; i < array.length; i++) {
      //    array[i].approver=document.getElementById('approver' + i) === null ? null : document.getElementById('approver' + i).value;
      //    array[i].approver_level=document.getElementById('approver_level' + i) === null ? null : document.getElementById('approver_level' + i).value;
      //    array[i].level_id=document.getElementById('level_id' + i) === null ? null : document.getElementById('level_id' + i).value;
      //    array[i].object_type=document.getElementById('object_type' + i) === null ? null : document.getElementById('object_type' + i).value;
      //    array[i].start_date=document.getElementById('start_date' + i) === null ? null : document.getElementById('start_date' + i).value;
      //    array[i].end_date=document.getElementById('end_date' + i) === null ? null : document.getElementById('end_date' + i).value;
      //    array[i].delegate_start_date=document.getElementById('delegate_start_date' + i) === null ? null : document.getElementById('delegate_start_date' + i).value;
      //    array[i].delgate_end_date=document.getElementById('delgate_end_date' + i) === null ? null : document.getElementById('delgate_end_date' + i).value;
      //    array[i].delegate_user_id=document.getElementById('delegate_user_id' + i) === null ? null : document.getElementById('delegate_user_id' + i).value;
      //    array[i].created_by=loginuser;

      //   ldata = ldata + 1;
      // }

      // payload.item = array; 
      // final["items"]=array;
      // console.log("ldata==>list count==>" + ldata);
      // console.log("----1>payload.item==>3" + JSON.stringify(payload.item));
      // console.log("Final Items" + JSON.stringify(final));

      // return {
      //   'isValid': isValid,
      //   'message': message,
      //   'payload': payload,
      //   'final'  : final
      // };

      var parts = [];
      var final = {};
      console.log("Array==>"+JSON.stringify(array));  
      final["items"] = array;
      console.log("Array 2==>"+JSON.stringify(final));  

      return {
        'isValid': isValid,
        'message': message,
        'final'  : final
      };

    }
  }
  
  return PageModule;
});
