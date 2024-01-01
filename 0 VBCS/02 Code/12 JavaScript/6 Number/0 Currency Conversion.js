<oj-form-layout id="id1">
<oj-input-text converter="[[ $functions.dataConvertor() ]]" required="true" value="{{ $variables.var1}}"
  label-hint="[[$application.translations.appBundle.input_text_label_hint]]"></oj-input-text>
</oj-form-layout>


//------------------------------------------------------------------- 

define(["ojs/ojconverter-number"], (ojconverter_number_1) => {
  'use strict';

  class PageModule {

    dataConvertor(){

        let Options =  {
        style: "currency",
        currency: "INR",
        pattern: "₹##,##,##0",
        };

      let convertor = new ojconverter_number_1.IntlNumberConverter(Options);

      return convertor;

    }



  }
  
  return PageModule;
});

