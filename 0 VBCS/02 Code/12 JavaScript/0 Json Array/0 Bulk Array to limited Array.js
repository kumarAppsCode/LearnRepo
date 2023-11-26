  PageModule.prototype.LineJs = function (array) {
    // console.log("===>" + JSON.stringify(array));
    let parts = [];
    for (let i = 1; i < array.length; i++){
      let obj = {};
      // console.log("finaal ==="+array[i].linelocationid);
      obj.LineLocationId=array[i].linelocationid;
      obj.LineNumber=array[i].lineNum;
      obj.ScheduleNumber=array[i].lineShipment;
      obj.Response=array[i].acknowledge;
      obj.RejectionReason=array[i].reason;
      parts.push(obj);
    }
    // console.log("====>"+parts);
    // console.log("====>"+JSON.stringify(parts));        
    return   parts;
  };
