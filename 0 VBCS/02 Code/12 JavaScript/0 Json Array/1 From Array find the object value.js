valueInArrayValidator(arrayOfValues) {
      return {
        validate: function (inputValue) {
          if (inputValue !== undefined && inputValue !== null) {
            const valid = arrayOfValues.includes(inputValue);

            console.log("ARAYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY VALUES: " + arrayOfValues);
            console.log("ARAYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY INPUT: " +inputValue);
            
            if (!valid) {
              throw new Error('Input value does not match any value in the array.');
            }
            return valid;
          }
          return true; // If inputValue is not provided, consider it as valid
        }
      };
};
	
=============
let birdsObj = [{
  id: '100',
  name: 'owl'
}, {
  id: '101',
  name: 'dove'
}, {
  id: '102',
  name: 'parrot'
}];

const birdName = 'owl';

var birdObject = birdsObj.find(bird => bird.name === birdName);

console.log(birdObject);
=====================

  let birdsObj = [{
    id: '100',
    name: 'owl'
  }, {
    id: '101',
    name: 'dove'
  }, {
    id: '102',
    name: 'parrot'
  }];

  const birdName = 'owl';

  var birdObj = birdsObj.filter(bird => bird.name === birdName);

  console.log(birdObj);
