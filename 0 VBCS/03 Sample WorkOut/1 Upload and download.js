<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.16.0/xlsx.full.min.js"></script>


define(['ojs/ojpagingdataproviderview', 'ojs/ojarraydataprovider', 'jsondiff', 'ojs/ojbufferingdataprovider'], function (PagingDataProviderView, ArrayDataProvider, JsonDiffPlugin, BufferingDataProvider) {
  'use strict';
  var bufferingDP;

  var JSON_DIFF = JsonDiffPlugin.create({
    arrays: {
      detectMove: false,
    },
    cloneDiffValues: false,
  });
  class PageModule {
    constructor(context) {
      this.editInProgressPromise = Promise.resolve();

    }
    sysDates() {
      var today = new Date();
      var dd = String(today.getDate()).padStart(2, '0');
      var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
      var yyyy = today.getFullYear();
      today = yyyy + '-' + mm + '-' + dd;
      return today;
    };

    //  Search lookup value 
    pageLine(array) {
      var data = new PagingDataProviderView(new ArrayDataProvider(
        array, {
        idAttribute: 'kare_detail_id'
      })); 0
      return data;
    };

    downloadExcel(data) {
      var createXLSLFormatObj = [];
      var xlsHeader = [
        "School",
        "Category",
        "Color",
        "Grade",
        "Product",
        "Item",
        "Item Desc",
        "Gender",
        "Remarks",
        "Avg Sale (SZ)",
        "HISTORICAL TREND% (SZ)",
        "Projected Sale (SZ)",
        "Kare Stock (WZ)",
        "Open Kare PO (SZ)",
        "Planned Procurement (SZ)",
        "To be procured (SZ)",
        "To be procured (WZ)",
        "HISTORICAL TREND% (WZ)",
        "Projected Sale (WZ)",
        "Kare stock (WZ)",
        "Open Kare PO (WZ)",
        "Planned Procurement (WZ)",
        "To be procured (WZ)",
        "To be procured (Total)",
        "Rate",
        "GST",
        "Value",
      ];
      createXLSLFormatObj.push(xlsHeader);
      $.each(data, function (index, value) {
        var innerRowData = [];
        innerRowData.push(value.school);
        innerRowData.push(value.category);
        innerRowData.push(value.color);
        innerRowData.push(value.grade);
        innerRowData.push(value.product);
        innerRowData.push(value.item);
        innerRowData.push(value.item_decs);
        innerRowData.push(value.gender);
        innerRowData.push(value.remarks);
        innerRowData.push(value.avg_sale_sz);
        innerRowData.push(value.historical_trend_sz);
        innerRowData.push(value.projected_sale_sz);
        innerRowData.push(value.kare_stock_wz);
        innerRowData.push(value.open_kare_po_sz);
        innerRowData.push(value.planned_procurement_sz);
        innerRowData.push(value.tobe_procured_sz);
        innerRowData.push(value.to_be_procured_wz);
        innerRowData.push(value.historical_trend_wz);
        innerRowData.push(value.projected_sale_wz);
        innerRowData.push(value.kare_stock_wz);
        innerRowData.push(value.open_kare_po_wz);
        innerRowData.push(value.planned_procurement_wz);
        innerRowData.push(value.tobe_procured_wz);
        innerRowData.push(value.tobe_procured_total);
        innerRowData.push(value.rate);
        innerRowData.push(value.gst);
        innerRowData.push(value.item_values);
        createXLSLFormatObj.push(innerRowData);

      });

      var filename = "Download.xlsx";
      /* Sheet Name */
      var ws_name = "Download";
      var wb = XLSX.utils.book_new(),
        ws = XLSX.utils.aoa_to_sheet(createXLSLFormatObj);
      /* Add worksheet to workbook */
      XLSX.utils.book_append_sheet(wb, ws, ws_name);
      /* Write workbook and Download */
      XLSX.writeFile(wb, filename);
    };

    processFile(fileSet) {
      var reader = new FileReader();
      return new Promise(function (resolve, reject) {
        var reader = new FileReader();
        reader.onloadend = function (e) {
          var data = e.target.result;
          var workbook = XLSX.read(data, { type: 'binary' });
          var first_worksheet = workbook.Sheets[workbook.SheetNames[0]];
          var jsonArr = XLSX.utils.sheet_to_json(first_worksheet, { header: 1 });
          resolve(jsonArr);
        };
        reader.readAsBinaryString(fileSet[0]);
      });
    };

    populateData(jsonArr, loginUser) {
      var parts = [];
      var final = {};
      var headerArray = [
        'school',
        'category',
        'color',
        'grade',
        'product',
        'item',
        'item_decs',
        'gender',
        'remarks',
        'avg_sale_sz',
        'historical_trend_sz',
        'projected_sale_sz',
        'kare_stock_wz',
        'open_kare_po_sz',
        'planned_procurement_sz',
        'tobe_procured_sz',
        'to_be_procured_wz',
        'historical_trend_wz',
        'projected_sale_wz',
        'kare_stock_wz',
        'open_kare_po_wz',
        'planned_procurement_wz',
        'tobe_procured_wz',
        'tobe_procured_total',
        'rate',
        'gst',
        'item_values'
      ];

      for (var j = 1; j < jsonArr.length; j++) {
        var obj = {};
        var partObject = {};
        for (var i = 0; i < jsonArr[0].length; i++) {
          var objName = headerArray[i];
          var objValue = jsonArr[j][i];
          obj[objName] = objValue;
          obj['created_by'] = loginUser;

        }
        parts.push(obj);
      }

      console.log(parts);
      final["parts"] = parts;

      return final;
    };


    createBufferingDP(baseDP) {
      bufferingDP = new BufferingDataProvider(baseDP);
      bufferingDP.addEventListener("submittableChange", (event) => {
        const submittableRows = event.detail;
      });
      return bufferingDP;
    };
    endEditing(rowKey) {
      if (rowKey !== this.rowBeingEditted) {
        return;
      }
      if (this.resolveHandler) {
        this.resolveHandler();
      }
    }
    isEditingFinished() {
      return this.editInProgressPromise;
    }
    updateItem(key, data) {
      // data.nss_count = data.student_count - data.lc_count + data.forcast_count;
      bufferingDP.updateItem({ metadata: { key: key }, data: data });
    };
    areDifferent(newValue, oldValue) {
      var diff = JSON_DIFF.diff(oldValue, newValue);
      return diff !== undefined;
    };
    isFormValid(detail, event) {
      if (detail !== undefined && detail.cancelEdit === true) {
        // skip validation
        return true;
      }
      // iterate over editable fields which are marked with "editable" class
      // and make sure they are valid:
      var table = event.target;
      var editables = table.querySelectorAll('.editable');
      for (var i = 0; i < editables.length; i++) {
        var editable = editables.item(i);
        editable.validate();
        // Table does not currently support editables with async validators
        // so treating editable with 'pending' state as invalid
        if (editable.valid !== 'valid') {
          return false;
        }
      }
      return true;
    };
    /**
     *
     * @param {String} arg1
     * @return {String}
     */
    startEditing(rowKey) {
      this.rowBeingEditted = rowKey;
      var self = this;
      this.editInProgressPromise = new Promise((resolve, reject) => {
        self.resolveHandler = resolve;
      });
    }
    setStatusToSubmitting() {
      let editItems = bufferingDP.getSubmittableItems();
      editItems.forEach(editItem => {
        this.setItemStatus(editItem, "submitting");
      });
      return editItems;
    }

    /**
     *
     * @param {String} arg1
     * @return {String}
     */
    setStatusToSubmitted(submittableItems) {
      submittableItems.forEach(editItem => {
        this.setItemStatus(editItem, "submitted");
      });
    }
    setItemStatus(editItem, status, error) {
      bufferingDP.setItemStatus(editItem, status, error);
    }
    createBatchPayload(user) {
      var payloads = [];
      var uniqueId = (new Date().getTime());
      let editItems = bufferingDP.getSubmittableItems();
      editItems.forEach(editItem => {
        var change = editItem.operation;
        var key = editItem.item.data.accountingRuleId;
        var record = JSON.parse(JSON.stringify(editItem.item.data));
        if (change === 'update') {
          payloads.push(record);
        }
      });
      return {
        "parts": payloads,
        "p_last_updated_by": user
      };
    }



  }


  return PageModule;
});
