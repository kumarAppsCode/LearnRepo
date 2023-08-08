define(['xlsx', 'jsondiff', 'ojs/ojbufferingdataprovider'], (XLSX, JsonDiffPlugin, BufferingDataProvider) => {
  'use strict';
  var bufferingDP;
  this.editInProgressPromise = Promise.resolve();
  var JSON_DIFF = JsonDiffPlugin.create({
    arrays: {
      detectMove: false,
    },
    cloneDiffValues: false,
  });

  class PageModule {

    /**
     *
     * @param {String} arg1
     * @return {String}
     */
    readFile(file, user, phase, categeory, school, ay, version) {
      var reader = new FileReader();
      return new Promise(function (resolve, reject) {
        var reader = new FileReader();
        reader.onloadend = function (e) {
          var data = e.target.result;
          var workbook = XLSX.read(data, { type: 'binary' });
          var first_worksheet = workbook.Sheets[workbook.SheetNames[0]];
          var jsonArr = XLSX.utils.sheet_to_json(first_worksheet, { header: 1, raw: "true" });
          var obj = {
            "nss_items":
              PageModule.prototype.populateData(jsonArr),
            "p_file_name": file[0].name,
            "p_file_mime_type": file[0].type,
            "p_created_by": user,
            "p_last_updated_by": user,
            "p_terms": phase,
            "category_info": categeory,
            "l_version": categeory,
            "school": school,
            "ay": ay
          };
          resolve(obj);
        };
        reader.readAsBinaryString(file[0]);
      });
    }
    populateData(jsonArr) {
      var data = jsonArr;
      var objData = [];
      for (var i = 1; i < data.length; i++) {
        objData[i - 1] = {};
        for (var k = 0; k < data[0].length && k < data[i].length; k++) {
          var key = data[0][k];
          objData[i - 1][key] = data[i][k];
        }
      }
      var Json = objData;
      return Json;
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
      data.nss_count = data.student_count - data.lc_count + data.forcast_count;
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
        "nss_items": payloads,
        "p_last_updated_by": user
      };
    }

    downloadFunc(path) {
      document.getElementById('my_iframe').src = 'resources/SampleData.xlsx';



      // var anchor = document.createElement('a');
      // anchor.setAttribute('href', path);
      // anchor.setAttribute('download', '');
      // document.body.appendChild(anchor);
      // anchor.click();
      // anchor.parentNode.removeChild(anchor);
    }
    getCalculateValues(ST, LC, FOR, currentRow) {
      // document.getElementById(currentRow).value = ST - LC + FOR;
    }
    getFilterCriteria(items, searchPayload) {
      var buildParams = [];
      for (var i = 0; i < items.length; i++) {
        // buildParams.push({
        //   "op": "$co",
        //   "attribute": "school",
        //   "value": items[i].lookup_values
        // })

      }

      if (searchPayload.AY) {
        buildParams.push({
          "op": "$co",
          "attribute": "ay",
          "value": searchPayload.AY
        })
      }
      if (searchPayload.Category) {
        buildParams.push({
          "op": "$co",
          "attribute": "category_info",
          "value": searchPayload.Category
        })
      }
      if (searchPayload.term) {
        buildParams.push({
          "op": "$co",
          "attribute": "term_phase",
          "value": searchPayload.term
        })
      }
      if (searchPayload.version) {
        buildParams.push({
          "op": "$co",
          "attribute": "version",
          "value": searchPayload.version
        })
      }
      return buildParams;
    }



  }

  return PageModule;
});
