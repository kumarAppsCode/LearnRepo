  onPageNaviFun (naviValue) {
        let navi=null;
        if(naviValue==="CREATE"){
          navi="POST";
        }else{
        navi="PUT";
      }
   // console.log("navi==>"+navi);
    return navi;
  };
  
  
    getPrimaryKey  (naviValue, keyValue) {
    var keyValueResult=null;
    console.log("naviValue Key===>"+naviValue);
    // console.log("Key===>"+keyValue);
    if(naviValue==="CREATE"){
        keyValueResult="0";
       console.log("ADD==>"+keyValueResult);
    }else{
      keyValueResult=keyValue;
     console.log("ELS==>"+keyValueResult);
    }
    return keyValueResult;
    
  };
