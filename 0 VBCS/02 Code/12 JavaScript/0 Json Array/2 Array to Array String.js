valueInArrayValidator(arrayOfValues) {
      return {
        validate: function (inputValue) {
          if (inputValue !== undefined && inputValue !== null) {
            // const valid = arrayOfValues.code.includes(inputValue);
const valid = arrayOfValues.includes(inputValue);
            console.log("ARAYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY VALUES: " + arrayOfValues);
            console.log("ARAYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY INPUT: " +inputValue);
           
            if (!valid) {
              throw new Error('Input value does not match any value in the array.' + arrayOfValues);
            }
            return valid;
          }
          return true; // If inputValue is not provided, consider it as valid
        }
      };
    };
 
 
 extractCodeValuesFromArray(dataArray) {
    if (!Array.isArray(dataArray)) {
        return [];
    }
   
    return dataArray.map(item => item.code);
}
