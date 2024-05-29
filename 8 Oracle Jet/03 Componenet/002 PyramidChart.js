<!-- pyramidChart -->
<div>
<oj-chart 
  id="pyramidChart"
  type="pyramid"
  data="[[dataProvider2]]"
  animation-on-display="auto"
  animation-on-data-change="auto"
  tooltip.renderer="[[tooltipFunc]]"
  style-defaults.three-d-effect="[[threeDValue]]">
  <template slot='itemTemplate' data-oj-as='item'>
      <oj-chart-item 
        value='[[item.data.revenue]]' 
        group-id='[[ [item.data.year] ]]' 
        series-id='[[item.data.product]]'> 
      </oj-chart-item>
  </template>
  </oj-chart>
</div>
**********************
          define(['../accUtils',
"require", "exports", "knockout", "ojs/ojbootstrap", 
"text!../singleItemData.json", 
"text!../revenueData.json", 
"ojs/ojarraydataprovider", "ojs/ojknockout", "ojs/ojchart"
],
 function(accUtils, require, exports, ko, ojbootstrap_1, piedata, pyramiddata, ArrayDataProvider) {
    function DashboardViewModel() {
  // pieChart 
      this.threeDValue = ko.observable("off");
      this.dataProvider = new ArrayDataProvider(JSON.parse(piedata), {
          keyAttributes: "id",
      });

   // Pyramid   
   this.threeDValue = ko.observable("off");   
   this.data = JSON.parse(pyramiddata);
   this.chartData = ko.observableArray(this.data["2015"]);
   this.dataProvider2 = new ArrayDataProvider(this.chartData, {
        keyAttributes: "id",
    });
    /* toggle buttons*/
    this.tooltipFunc = (dataContext) => {
      return { insert: `${dataContext.series} : ${dataContext.value}B` };
    };

    }

    return DashboardViewModel;
  }
);
************************************
  {
    "2015" : [
        {
            "id": "0",
            "year": "2015",
            "product": "Phone",
            "revenue": 155.50
        },
        {
            "id": "1",
            "year": "2015",
            "product": "Tablet",
            "revenue": 21.326
        },
        {
            "id": "2",
            "year": "2015",
            "product": "Computer",
            "revenue": 25.27
        }
      ]
}
