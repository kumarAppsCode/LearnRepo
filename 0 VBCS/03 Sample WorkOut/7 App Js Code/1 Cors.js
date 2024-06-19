/* Copyright (c) 2023, Oracle and/or its affiliates */

define(['https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js', 'https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.4/moment.min.js', 'https://cdnjs.cloudflare.com/ajax/libs/x2js/1.2.0/xml2json.min.js', 'vb/helpers/rest', 'oj-sp/spectra-shell/config/config'], function (CryptoJS, Moment, XMLToJSON, Rest) {
  'use strict';

  var AppModule = function AppModule() { };
  AppModule.prototype.$application = {};

  AppModule.prototype.initPage = function (app) {
    AppModule.prototype.$application = app;
  };

  function parseJwt(token) {
    var base64Url = token.split('.')[1];
    var base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    var jsonPayload = decodeURIComponent(window.atob(base64).split('').map(function (c) {
      return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
    }).join(''));

    return JSON.parse(jsonPayload);
  }

  AppModule.prototype.getUsername = function () {
    // var jwt = AppModule.prototype.$application.variables.jwt;

    // if (jwt) {
    //   return parseJwt(jwt).sub;
    // } else {
    //   // return AppModule.prototype.$application.user.username;
    //   return "CASEY.BROWN";
    // }
    //return AppModule.prototype.$application.user.username;
    return AppModule.prototype.$application.variables.user.username;

  };
  AppModule.prototype.assignUsername = function () {
    var jwt = AppModule.prototype.$application.variables.jwt;

    if (jwt) {
      console.log(jwt)
      AppModule.prototype.$application.variables.fullToken = jwt;

      AppModule.prototype.$application.variables.user.username = AppModule.prototype.decryptData(AppModule.prototype.$application.variables.randomValue);
      let user = AppModule.prototype.$application.variables.user.username;


    }
    if (window.location.href.indexOf("https://clh-visual-builder-studio-cleanharbors40-iad.developer.ocp.oraclecloud.com/clh-visual-builder-studio-cleanharbors40-iad/s2/clh-visual-builder-studio-cleanharbors40-iad_clh-extensions_6522/vbdt/design/") > -1) {

      AppModule.prototype.$application.variables.user.username = "CLHOICSCMUSER@cleanharbors.com"; //integration@cleanharbors.com
    }
  };
  AppModule.prototype.saveFilter = function (session, filters) {
    sessionStorage.setItem(session, JSON.stringify(filters));
  };

  AppModule.prototype.getFilter = function (session) {
    return JSON.parse(sessionStorage.getItem(session));
  };

  AppModule.prototype.dateIsValid = function (dateStr) {
    const regex = /^\d{4}-\d{2}-\d{2}$/;
    if (dateStr.match(regex) === null) {
      return false;
    }

    const date = new Date(dateStr);
    const timestamp = date.getTime();
    if (typeof timestamp !== 'number' || Number.isNaN(timestamp)) {
      return false;
    }

    return date.toISOString().startsWith(dateStr);
  }

  // Return criteria fro sdp usage --- need to combine use with trasform if using ords, else no need
  AppModule.prototype.parseFilter = function (column, keywords, fix_filter, subArray, relationshipKey) {
    console.log(column)
    console.log(keywords)
    var result = [];
    var subTableResult = [];
    var subTableResult2 = [];
    // looping multi keywords
    for (let y = 0; y < keywords.length; y++) {
      let value = keywords[y].value;
      console.log(typeof value);
      var sub_result = [];

      //search for subtable data
      var ifDateRange = AppModule.prototype.determineIfDateRange(value.replace("to", "-"));
      console.log(ifDateRange);
      var searchFromSubTable = [];
      var allDateValue = "";
      if (ifDateRange) {
        allDateValue = AppModule.prototype.findAllDateRange(value.replace("to", "-"));
        console.log(allDateValue);
        for (let i = 0; i < allDateValue.length; i++) {
          searchFromSubTable.push(...AppModule.prototype.findTextInArrayObjects(subArray, convertDateFormat(allDateValue[i]), relationshipKey));
          console.log(searchFromSubTable);
        }
      } else {
        searchFromSubTable = AppModule.prototype.findTextInArrayObjects(subArray, convertDateFormat(value), relationshipKey);
      }

      //subTableResult.push(...searchFromSubTable);

      function convertDateFormat(inputDate) {
        // Define a regular expression to match the format MM/DD/YYYY
        var dateRegex = /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/;

        // Use console.log for debugging
        console.log('Original input date:', inputDate);

        // Use the regex to test if the inputDate matches the expected format
        if (dateRegex.test(inputDate)) {
          // If it matches, extract the components and construct the new format
          var [, month, day, year] = dateRegex.exec(inputDate);
          var convertedDate = year + '-' + month.padStart(2, '0') + '-' + day.padStart(2, '0');

          // Use console.log for debugging
          console.log('Converted date:', convertedDate);

          return convertedDate;
        } else {
          // If it doesn't match, return the original input
          console.log('Input date does not match expected format. Returning original input.');
          return inputDate;
        }
      }

      console.log(subTableResult)
      // looping column
      for (let x = 0; x < column.length; x++) {
        if (column[x].filter) { // only for column filter : true
          switch (column[x].filter) {
            case "date":
              var date_result = [];
              if (ifDateRange) {
                try {
                  date_result.push({
                    attribute: column[x].field,
                    op: "$ge",
                    // value: new Moment(value,'MM/DD/YYYY').format("YYYY-MM-DD")+"T00:00:00"
                    value: convertDateFormat(allDateValue[0]) + 'T00:00:00'
                  });
                  date_result.push({
                    attribute: column[x].field,
                    op: "$le",
                    // value: new Moment(value,'MM/DD/YYYY').format("YYYY-MM-DD")+"T00:00:00"
                    value: convertDateFormat(allDateValue[allDateValue.length - 1]) + 'T23:59:59'
                  });
                  sub_result.push({
                    op: '$and',
                    criteria: date_result
                  })
                } catch (error) {
                }
              } else {

                let objectDate = new Date(value);
                if (objectDate.getFullYear() < 1970) {
                  continue;
                }
                let day = objectDate.getDate();
                let month = objectDate.getMonth() + 1;
                let year = objectDate.getFullYear();
                var filter_date = year + "-" + ((month < 10) ? "0" + month : month) + "-" + ((day < 10) ? "0" + day : day);
                //if (filter_date!='NaN-NaN-NaN'){
                if (AppModule.prototype.dateIsValid(filter_date)) {
                  try {
                    date_result.push({
                      attribute: column[x].field,
                      op: "$ge",
                      // value: new Moment(value,'MM/DD/YYYY').format("YYYY-MM-DD")+"T00:00:00"
                      value: filter_date.slice(0, 10) + 'T00:00:00'
                    });
                    date_result.push({
                      attribute: column[x].field,
                      op: "$le",
                      // value: new Moment(value,'MM/DD/YYYY').format("YYYY-MM-DD")+"T00:00:00"
                      value: filter_date.slice(0, 10) + 'T23:59:59'
                    });
                    sub_result.push({
                      op: '$and',
                      criteria: date_result
                    })
                  } catch (error) {
                  }
                }
              }
              break;
            default:
              sub_result.push({
                attribute: column[x].field,
                op: "$co",
                value: value
              });
              break;
          }
        }
      }
      subTableResult2 = [...new Set(searchFromSubTable)];
      console.log(subTableResult2);
      if (subTableResult2) {
        for (let x = 0; x < subTableResult2.length; x++) {
          sub_result.push({
            attribute: 'id',
            op: "$eq",
            value: subTableResult2[x]
          });
        }
      }
      result.push({
        op: '$or',
        criteria: sub_result
      });

    };
    // var subTableResult2 = [...new Set(subTableResult)];
    // console.log(subTableResult2);
    // console.log(typeof subTableResult2);
    // var withDuplicateSubResult = AppModule.prototype.findDuplicate(subTableResult);
    // console.log(withDuplicateSubResult);
    // if (withDuplicateSubResult) {
    //   for (let x = 0; x < withDuplicateSubResult.length; x++) {
    //     subTableResult2.push({
    //       attribute: 'id',
    //       op: "$eq",
    //       value: withDuplicateSubResult[x]
    //     });
    //   }
    // }
    // result.push({
    //   op: '$or',
    //   criteria: subTableResult2
    // });

    console.log(fix_filter);
    var test = result;
    if (fix_filter) {
      result.push(...fix_filter);

      // for (let x = 0; x < fix_filter.length; x++) {
      //   result.push({
      //     attribute: fix_filter[x].attribute,
      //     op: fix_filter[x].op,
      //     value: fix_filter[x].value
      //   });
      // }
    }
    // if (subTableResult2) {
    //   var sub_result = [];
    //   for (let x = 0; x < subTableResult2.length; x++) {
    //     sub_result.push({
    //       attribute: 'id',
    //       op: "$eq",
    //       value: subTableResult2[x]
    //     })
    //   }
    //   result.push({
    //     op: '$or',
    //     criteria: sub_result
    //   });
    // }


    console.log(result)
    return {
      op: '$and',
      criteria: result
    };
  };

  AppModule.prototype.findTextInArrayObjects = function (arr, searchText, returnedKey) {
    const results = [];
    console.log(searchText);
    console.log(returnedKey);
    if (['APPROVED', 'CANCELED', 'INCOMPLETE', 'PENDING', 'WITHDRAWN'].includes(searchText.toUpperCase())) {
      return results;
    }
    for (const obj of arr) {
      const jsonString = JSON.stringify(obj).toLowerCase();
      console.log(jsonString);
      if (jsonString.includes(searchText.toLowerCase())) {
        console.log(obj);
        results.push(obj[returnedKey]);
      }
    }
    console.log(results);
    return results;//return id of object([1,55,23,1])
  };

  AppModule.prototype.findAllDateRange = function (inputText) {
    function findDateRanges(inputString) {
      // Define the regular expression pattern for the date range
      var pattern = /\b\d{1,2}\/\d{1,2}\/\d{4}\-\d{1,2}\/\d{1,2}\/\d{4}\b/g;

      // Use the exec method to find all matches in the input string
      var matches = [];
      var match;
      while ((match = pattern.exec(inputString)) !== null) {
        matches.push(match[0]);
      }

      // Process each match to extract the start and end dates
      var dateRanges = [];
      for (var i = 0; i < matches.length; i++) {
        var dates = matches[i].split('-');
        var startDate = new Date(dates[0]);
        var endDate = new Date(dates[1]);
        dateRanges.push({ start: startDate, end: endDate });
      }

      return dateRanges;
    }

    function formatDate(date) {
      var month = (date.getMonth() + 1).toString().padStart(2, '0');
      var day = date.getDate().toString().padStart(2, '0');
      var year = date.getFullYear().toString();
      return month + '/' + day + '/' + year;
    }

    function generateDateRange(inputString) {
      var dateRanges = findDateRanges(inputString.replace(/\s/g, ''));
      var result = [];

      for (var i = 0; i < dateRanges.length; i++) {
        var startDate = dateRanges[i].start;
        var endDate = dateRanges[i].end;

        // Generate dates between start and end (inclusive)
        var currentDate = new Date(startDate);
        while (currentDate <= endDate) {
          result.push(formatDate(currentDate));
          currentDate.setDate(currentDate.getDate() + 1);
        }
      }

      return result;
    }
    var result = generateDateRange(inputText);
    console.log("All Date Range:");
    console.log(result);
    return result;
  }

  AppModule.prototype.determineIfDateRange = function (inputText) {
    var pattern = /\b\d{1,2}\/\d{1,2}\/\d{4}\-\d{1,2}\/\d{1,2}\/\d{4}\b/g;
    if (pattern.test(inputText.replace(/\s/g, ''))) {
      return true;
    } else {
      return false;
    }
  }


  AppModule.prototype.findDuplicate = function (arr) {
    let seen = new Set();
    let duplicates = new Set();

    for (let item of arr) {
      if (seen.has(item)) {
        duplicates.add(item);
      } else {
        seen.add(item);
      }
    }

    return Array.from(duplicates);
  }

  AppModule.prototype.debug = function (a, b, c, d, e, f, g) {
    console.log('==========================DEBUG==========================');
    console.log(a);
    console.log(b);
    console.log(c);
    console.log(d);
    console.log(e);
    console.log(f);
    console.log(g);
    console.log('========================END DEBUG========================');

  };

  AppModule.prototype.toUtcDate = function (date) {
    console.log('000000000000000000000000000000000000000000000000000000000000');
    console.log(date);
    // Get user's timezone offset in minutes
    if (date == null) {
      return date;
    }
    //var userTimezoneOffset = new Date().getTimezoneOffset();
    var time = Moment(date).utc().format("YYYY-MM-DDTHH:mm:ss");
    var userTimezoneOffset = Math.abs(Moment(time).zone());
    console.log("Offset timezone amount: " + userTimezoneOffset);
    // Convert the offset to milliseconds
    var timezoneOffsetMs = userTimezoneOffset * 60 * 1000;

    // Get the current date and time in the user's timezone
    var currentDate = new Date();

    // Adjust the current date by the timezone offset
    var currentUtcDate = new Date(currentDate.getTime() + timezoneOffsetMs);

    // Convert the input date to UTC
    // function convertToUtc(inputDate) {
    // Get the input date in the user's timezone
    var userDate = new Date(date.slice(0, 10));

    // Adjust the input date by the timezone offset
    var userUtcDate = new Date(userDate.getTime() + timezoneOffsetMs);

    // Convert the user's timezone date to UTC
    var utcDate = new Date(userUtcDate.getTime() - userUtcDate.getTimezoneOffset() * 60 * 1000);
    console.log(utcDate.toISOString()); // Output: "2023-06-28T12:00:00.000Z"

    return userUtcDate;
  };

  AppModule.prototype.toMinMaxDate = function (date, type) {
    if (!date) {
      return "";
    }
    var day = new Date(date);
    if (date.length <= 10) {
      var time = Moment(date).utc().format("YYYY-MM-DDTHH:mm:ss");
      var userTimezoneOffset = Math.abs(Moment(time).zone());
      var userDate = new Date(date.slice(0, 10));
      day = new Date(userDate.getTime() + (userTimezoneOffset * 60 * 1000)).toISOString();
      console.log(day);
    }
    if (type === "min") {
      return new Date(Date.parse(day) + (1 * 1000 * 60 * 60 * 24)).toLocaleDateString('en-CA');
    } else if (type === 'max') {
      return new Date(Date.parse(day) - (1 * 1000 * 60 * 60 * 24)).toLocaleDateString('en-CA');
    } else {
      return new Date(day).toLocaleDateString('en-CA');
    }
  };


  AppModule.prototype.decryptData = function (data) {
    const passphrase = 'VehS2R2acgND$C';
    const bytes = CryptoJS.AES.decrypt(data, passphrase);
    const originalText = bytes.toString(CryptoJS.enc.Utf8);
    return originalText;
  };

  AppModule.prototype.getBIPResult = function (payload) {
    return new Promise(function (resolve, reject) {

      //obtained from step #1. Note MESSAGEID, this will be replaced later

      const endpoint = "fusionRestApi/getBIP";
      //obtained from service connnection definition

      //make the call and parse the response
      Rest.get(endpoint).body(payload).fetch().then(
        response => {
          // const result = $.parseXML(response.body).getElementsByTagName("requestId")[0].textContent;
          console.log(response);
          const result = $.parseXML(response.body).getElementsByTagName("ns2:reportBytes")[0].textContent;
          console.log(result);
          let xmlText = decodeURIComponent(escape(atob(result)));

          console.log(xmlText);
          var x2js = new XMLToJSON();
          let jsonParse = x2js.xml_str2json(xmlText);
          console.log(jsonParse);
          // let dom = parseXml(xmlText);
          // console.log(dom);
          // let jsonString = xml2json(dom);
          // jsonString=jsonString.slice(0,1)+jsonString.slice(11);
          // console.log(jsonString);
          // let jsonParse=JSON.parse(jsonString);
          // console.log(jsonParse);

          resolve(jsonParse);
        });

    });

    function parseXml(xml) {
      var dom = null;
      if (window.DOMParser) {
        try {
          dom = (new DOMParser()).parseFromString(xml, "text/xml");
          console.log(dom)
        }
        catch (e) { dom = null; }
      }
      else if (window.ActiveXObject) {
        try {
          dom = new ActiveXObject('Microsoft.XMLDOM');
          dom.async = false;
          if (!dom.loadXML(xml)) // parse error ..

            window.alert(dom.parseError.reason + dom.parseError.srcText);
        }
        catch (e) { dom = null; }
      }
      else
        alert("cannot parse xml string!");
      return dom;
    }


    function xml2json(xml, tab) {
      var X = {
        toObj: function (xml) {
          var o = {};
          if (xml.nodeType == 1) {   // element node ..
            if (xml.attributes.length)   // element with attributes  ..
              for (var i = 0; i < xml.attributes.length; i++)
                o["@" + xml.attributes[i].nodeName] = (xml.attributes[i].nodeValue || "").toString();
            if (xml.firstChild) { // element has child nodes ..
              var textChild = 0, cdataChild = 0, hasElementChild = false;
              for (var n = xml.firstChild; n; n = n.nextSibling) {
                if (n.nodeType == 1) hasElementChild = true;
                else if (n.nodeType == 3 && n.nodeValue.match(/[^ \f\n\r\t\v]/)) textChild++; // non-whitespace text
                else if (n.nodeType == 4) cdataChild++; // cdata section node
              }
              if (hasElementChild) {
                if (textChild < 2 && cdataChild < 2) { // structured element with evtl. a single text or/and cdata node ..
                  X.removeWhite(xml);
                  for (var n = xml.firstChild; n; n = n.nextSibling) {
                    if (n.nodeType == 3)  // text node
                      o["#text"] = X.escape(n.nodeValue);
                    else if (n.nodeType == 4)  // cdata node
                      o["#cdata"] = X.escape(n.nodeValue);
                    else if (o[n.nodeName]) {  // multiple occurence of element ..
                      if (o[n.nodeName] instanceof Array)
                        o[n.nodeName][o[n.nodeName].length] = X.toObj(n);
                      else
                        o[n.nodeName] = [o[n.nodeName], X.toObj(n)];
                    }
                    else  // first occurence of element..
                      o[n.nodeName] = X.toObj(n);
                  }
                }
                else { // mixed content
                  if (!xml.attributes.length)
                    o = X.escape(X.innerXml(xml));
                  else
                    o["#text"] = X.escape(X.innerXml(xml));
                }
              }
              else if (textChild) { // pure text
                if (!xml.attributes.length)
                  o = X.escape(X.innerXml(xml));
                else
                  o["#text"] = X.escape(X.innerXml(xml));
              }
              else if (cdataChild) { // cdata
                if (cdataChild > 1)
                  o = X.escape(X.innerXml(xml));
                else
                  for (var n = xml.firstChild; n; n = n.nextSibling)
                    o["#cdata"] = X.escape(n.nodeValue);
              }
            }
            if (!xml.attributes.length && !xml.firstChild) o = null;
          }
          else if (xml.nodeType == 9) { // document.node
            o = X.toObj(xml.documentElement);
          }
          else
            alert("unhandled node type: " + xml.nodeType);
          return o;
        },
        toJson: function (o, name, ind) {
          var json = name ? ("\"" + name + "\"") : "";
          if (o instanceof Array) {
            for (var i = 0, n = o.length; i < n; i++)
              o[i] = X.toJson(o[i], "", ind + "\t");
            json += (name ? ":[" : "[") + (o.length > 1 ? ("\n" + ind + "\t" + o.join(",\n" + ind + "\t") + "\n" + ind) : o.join("")) + "]";
          }
          else if (o == null)
            json += (name && ":") + "null";
          else if (typeof (o) == "object") {
            var arr = [];
            for (var m in o)
              arr[arr.length] = X.toJson(o[m], m, ind + "\t");
            json += (name ? ":{" : "{") + (arr.length > 1 ? ("\n" + ind + "\t" + arr.join(",\n" + ind + "\t") + "\n" + ind) : arr.join("")) + "}";
          }
          else if (typeof (o) == "string")
            json += (name && ":") + "\"" + o.toString() + "\"";
          else
            json += (name && ":") + o.toString();
          return json;
        },
        innerXml: function (node) {
          var s = ""
          if ("innerHTML" in node)
            s = node.innerHTML;
          else {
            var asXml = function (n) {
              var s = "";
              if (n.nodeType == 1) {
                s += "<" + n.nodeName;
                for (var i = 0; i < n.attributes.length; i++)
                  s += " " + n.attributes[i].nodeName + "=\"" + (n.attributes[i].nodeValue || "").toString() + "\"";
                if (n.firstChild) {
                  s += ">";
                  for (var c = n.firstChild; c; c = c.nextSibling)
                    s += asXml(c);
                  s += "</" + n.nodeName + ">";
                }
                else
                  s += "/>";
              }
              else if (n.nodeType == 3)
                s += n.nodeValue;
              else if (n.nodeType == 4)
                s += "<![CDATA[" + n.nodeValue + "]]>";
              return s;
            };
            for (var c = node.firstChild; c; c = c.nextSibling)
              s += asXml(c);
          }
          return s;
        },
        escape: function (txt) {
          return txt.replace(/[\\]/g, "\\\\")
            .replace(/[\"]/g, '\\"')
            .replace(/[\n]/g, '\\n')
            .replace(/[\r]/g, '\\r');
        },
        removeWhite: function (e) {
          e.normalize();
          for (var n = e.firstChild; n;) {
            if (n.nodeType == 3) {  // text node
              if (!n.nodeValue.match(/[^ \f\n\r\t\v]/)) { // pure whitespace text node
                var nxt = n.nextSibling;
                e.removeChild(n);
                n = nxt;
              }
              else
                n = n.nextSibling;
            }
            else if (n.nodeType == 1) {  // element node
              X.removeWhite(n);
              n = n.nextSibling;
            }
            else                      // any other node
              n = n.nextSibling;
          }
          return e;
        }
      };
      if (xml.nodeType == 9) // document node
        xml = xml.documentElement;
      var json = X.toJson(X.toObj(X.removeWhite(xml)), xml.nodeName, "\t");
      return "{\n" + tab + (tab ? json.replace(/\t/g, tab) : json.replace(/\t|\n/g, "")) + "\n}";
    }
    // function xmlToJson(xml) {
    //   // Create the return object
    //   let obj = {};

    //   if (xml.nodeType === 1) { // element
    //     // do attributes
    //     if (xml.attributes.length > 0) {
    //       obj["@attributes"] = {};
    //       for (let j = 0; j < xml.attributes.length; j++) {
    //         const attribute = xml.attributes.item(j);
    //         obj["@attributes"][attribute.nodeName] = attribute.nodeValue;
    //       }
    //     }
    //   } else if (xml.nodeType === 3) { // text
    //     obj = xml.nodeValue.trim();
    //   }

    //   // do children
    //   if (xml.hasChildNodes()) {
    //     for (let i = 0; i < xml.childNodes.length; i++) {
    //       const item = xml.childNodes.item(i);
    //       const nodeName = item.nodeName;
    //       if (typeof obj[nodeName] === "undefined") {
    //         obj[nodeName] = xmlToJson(item);
    //       } else {
    //         if (typeof obj[nodeName].push === "undefined") {
    //           const old = obj[nodeName];
    //           obj[nodeName] = [];
    //           obj[nodeName].push(old);
    //         }
    //         obj[nodeName].push(xmlToJson(item));
    //       }
    //     }
    //   }
    //   return obj;
    // }
  }
  AppModule.prototype.removeDuplicates = function (arr, prop) {
    return arr.filter((obj, index, array) => {
      return array.map(mapObj => mapObj[prop]).indexOf(obj[prop]) === index;
    });
  }

  /**
   *
   * @param {String} arg1
   * @return {String}
   */
  AppModule.prototype.legalJs = function (po_header, legaId) {
      // console.log("po header id ===a" + JSON.stringify(po_header));
      let poHeaderId="null";
      console.log("PO==>legaId"+legaId);
      for(let i=0; i<po_header.length; i++){
        if(legaId === po_header[i].SoldToLegalEntityId){
          // console.log("PO==>po header id ==="+po_header[i].POHeaderId);
          // console.log("PO==>SoldToLegalEntityId ==="+po_header[i].SoldToLegalEntityId);
          poHeaderId=po_header[i].POHeaderId;
        }
      }
      return poHeaderId; 
  };


  /**
   *
   * @param {String} arg1
   * @return {String}
   */
  AppModule.prototype.legalJsStatus = function (po_header, legaId) {
      // console.log("po header id ===a" + JSON.stringify(po_header));
      let statusCode="null";
      console.log("PO==>legaId"+legaId);
      for(let i=0; i<po_header.length; i++){
        if(legaId === po_header[i].SoldToLegalEntityId){
          // console.log("PO==>po header id ==="+po_header[i].POHeaderId);
          // console.log("PO==>SoldToLegalEntityId ==="+po_header[i].SoldToLegalEntityId);
          console.log("PO==>StatusCode ==="+po_header[i].StatusCode);
          // statusCode=po_header[i].StatusCode;
          statusCode=po_header[i].Status;
        }
      }
      return statusCode;
  };


  /**
   *
   * @param {String} arg1
   * @return {String}
   */
  AppModule.prototype.poLineQueryJs = function () {
    return "poLineLocationId IS NOT NULL" ;
  };


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


  return AppModule;
});

