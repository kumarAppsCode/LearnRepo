  /**
   *
   * @param {String} arg1
   * @return {String}
   */
  AppModule.prototype.poModifyJs = function (prArray, freightTerms) {
    // console.log("prArray===>" + JSON.stringify(prArray));
    let finalObj={};
    // console.log("freightTerms==>"+freightTerms);

    let hdrObj={};
    let linesArray={
      lines:[]
    };


    linesArray.ChangeOrderDescription="change order";
    linesArray.ChangeOrderInitiatingParty="BUYER";
    linesArray.FreightTerms=freightTerms;
    
    for (let i = 0; i < prArray.length; i++){
            let schedules=[];
            let DFF=[];
      //  console.log("prArray==>poLineHeaderId"+prArray[i].poLineHeaderId); 
      //  console.log("prArray==>lineid"+prArray[i].poLineId);
      //  console.log("prArray==>linelocation"+prArray[i].poLineLocationId); 
      //  console.log("prArray==>id"+prArray[i].id);
      //  console.log("prArray==>quantity"+prArray[i].quantity);
      //  console.log("prArray==>needByDate"+prArray[i].needByDate);
      //  console.log("prArray==>shipVia"+prArray[i].shipVia);
      //  console.log("========");
      // ***********************************
        DFF.push({
          // "shipVia":prArray[i].shipVia
          "shipVia":"Air"
        });
        schedules.push({
          "LineLocationId":prArray[i].poLineLocationId,
          "RequestedDeliveryDate":prArray[i].needByDate,
          "PromisedDeliveryDate":prArray[i].needByDate,
          DFF
        });

    // console.log("prArray==>"+JSON.stringify(schedules));

      linesArray.lines.push({
        "POLineId":prArray[i].poLineId,
        "Quantity":prArray[i].quantity,
         schedules
      });
    }

    // console.log("prArray==>"+JSON.stringify(linesArray));

    return linesArray;
  };




{
	"ChangeOrderDescription": "change order",
	"ChangeOrderInitiatingParty": "REQUESTER",
	"FreightTerms": "Collect",
	"lines": [
		{
			"POLineId": 300000168908392,
			"Quantity": 5,
			"schedules": [
				{
					"LineLocationId": 300000079220676,
					"RequestedDeliveryDate": "2030-06-19",
					"PromisedDeliveryDate": "2030-06-19",
					"DFF": [
						{
							"shipVia": "Air"
						}
					]
				}
			]
		}
	]
}


