var UTIL ={
    server_url : "http://127.0.0.1:7101/Schedule/jersey/ScheduleServices/",
    app_name : "Scheduler Management System",
    customer_name : "Company",
    env_name : "DV",

    message_timeout : 2000,

    translate: function(key){
      if(key && key.trim().length > 0){
        return oj.Translations.getTranslatedString(key);
      }
    }
}


async function callGetService(serviceName) {
    return new Promise(function(resolve, reject) {
      var headers = {};
      headers['Content-Type'] = 'application/json';

      fetch(UTIL.server_url + serviceName, {
        method: 'GET',
        headers: headers,
        mode: 'cors'
      })
      .then(resp => resp.json())
      .then((data) =>  {
        resolve(data)
      })
      .catch((error) => {
        reject(error)
      })
    })
  }


  async function callGetServiceWithOneParam(serviceName, paramName, paramValue) {
    return new Promise(function(resolve, reject) {
      var headers = {};
      headers['Content-Type'] = 'application/json';

      fetch(UTIL.server_url + serviceName + '?' + paramName + '=' + paramValue, {
        method: 'GET',
        headers: headers,
        mode: 'cors'
      })
      .then(resp => resp.json())
      .then((data) =>  {
        resolve(data)
      })
      .catch((error) => {
        reject(error)
      })
    })
  }

  async function callPostService(serviceName, input) {
    return new Promise(function(resolve, reject) {
      var headers = {};
      headers['Content-Type'] = 'application/json';

      var bodyPart = JSON.stringify(input);

      fetch(UTIL.server_url + serviceName, {
        method: 'POST',
        headers: headers,
        mode: 'cors',
        body:  bodyPart
      })
      .then(resp => resp.json())
      .then((data) =>  {
        resolve(data)
      })
      .catch((error) => {
        reject(error)
      })
    })
  }

  async function callPostServiceReturnString(serviceName, input) {
    return new Promise(function(resolve, reject) {
      var headers = {};
      headers['Content-Type'] = 'application/json';

      var bodyPart = JSON.stringify(input);

      fetch(UTIL.server_url + serviceName, {
        method: 'POST',
        headers: headers,
        mode: 'cors',
        body:  bodyPart
      })
      .then(resp => resp.text())
      .then((data) =>  {
        resolve(data)
      })
      .catch((error) => {
        reject(error)
      })
    })
  }

  function setSession(key, value){
    sessionStorage.setItem(key, value);
  }

  function getSession (key){
    return sessionStorage.getItem(key);
  }

  function isNoDataInSession(key){
    var data = sessionStorage.getItem(key);
    return data === undefined || data === null || data === '';
  }

  function setJSONSession(key, value){
    sessionStorage.setItem(key, JSON.stringify(value));
  }

  function getJSONSession (key){
    return JSON.parse(sessionStorage.getItem(key));
  }
