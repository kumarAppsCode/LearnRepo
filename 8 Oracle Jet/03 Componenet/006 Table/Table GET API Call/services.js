define(['../accUtils',"require", "exports", "knockout", "ojs/ojbootstrap", 
"ojs/ojarraydataprovider", 
"text!../Json/departmentData.json", 
"ojs/ojtable", "ojs/ojknockout"
],
 function(accUtils,require, exports, ko, ojbootstrap_1, 
         ArrayDataProvider, deptData
         ) {

    // Connect  
    function ServicesViewModel() {
      this.connected = () => {
        accUtils.announce('Services page loaded.', 'assertive');
        document.title = "Services";
      };

      // Get Services
      this.serviceArray =ko.observableArray([]);
      // Get Services
      callGetService('service/getServices')
      .then((response) =>{
        this.serviceArray(response.service);
      })
      .catch((error) =>{
        console.log("Error while calling service");
      })

      this.servicedataprovider = new ArrayDataProvider(this.serviceArray, {
          keyAttributes: "serviceId",
          implicitSort: [{ attribute: "serviceId", direction: "ascending" }],
      });
      





    }
    return ServicesViewModel;
  }
);
