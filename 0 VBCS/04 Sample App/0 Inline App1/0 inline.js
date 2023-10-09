define([], () => {
  'use strict';

  class PageModule {

    /**
     *
     * @param {String} arg1
     * @return {String}
     */
    ADPDataJs(arrayJs) {
      var parts = [];
      var final = {};
      console.log("Array==>"+JSON.stringify(arrayJs));  
      final["parts"] = arrayJs;
      console.log("Array 2==>"+JSON.stringify(final));  
      return JSON.stringify(final);
    }
  }
  
  return PageModule;
});
