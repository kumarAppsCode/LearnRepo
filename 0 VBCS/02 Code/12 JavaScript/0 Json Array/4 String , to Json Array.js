define([], () => {
  'use strict';

  class PageModule {

// size count 
  getSizeOfOneArray(array) {
  console.log("==>length==>"+array.length);
  if (array.length > 0){
      return false;
    }else{
      return true;
    }
  }
  //===>
  addRemoveIdfromArray(id, array, type){

console.log("==>id"+id);
console.log("==>"+array);
console.log("==>"+type);
    let arr = [];
    arr = array;
    console.error("bef oper");
    console.error(arr);
    if (type === "ADD") {
       if(! array.includes(id)){
          arr.push(id);
       }
    }
    else {
      let index = arr.indexOf(id);
      if (index > -1) {
        arr.splice(index, 1);
      }
    } 
    console.error("after oper");
    console.error("new len==>"+arr.length);
    console.error(arr);

    return arr;
  } 
  // ==>
  
  
    /**
     *
     * @param {String} arg1
     * @return {String}
     */
    arrayPreparationJs(arraySelect, p_RecordStatus, p_ApprovalStatus, p_ApprovedBy,p_ApproverNotes,p_BatchApproverNotes) {

    let parts = [];    
    var final = {};
    console.log("arraySelect==>"+arraySelect);

  for (let i =0; i < arraySelect.length; i++){
    let obj = {};
      console.log(arraySelect[i]);

    obj.InvoiceId=arraySelect[i];
    obj.RecordStatus=p_RecordStatus;
    obj.ApprovalStatus=p_ApprovalStatus;
    obj.ApprovedBy=p_ApprovedBy
    obj.ApproverNotes=p_ApproverNotes;
    obj.BatchApproverNotes=p_BatchApproverNotes;
     parts.push(obj); 
  }    

    // console.log("====>"+parts);
    console.log("====>"+JSON.stringify(parts)); 
    final["items"] = parts;
    return final;

  }
  
  }
  return PageModule;
});



