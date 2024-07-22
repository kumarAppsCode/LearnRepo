define([], () => {
  'use strict';

  class PageModule {

    /**
     *
     * @param {String} arg1
     * @return {String}
     */
    onCalculateGeo(arg1) {
      const centerLat = 23.593497;  // 4i Room latitude
      const centerLon = 58.4035575; // 4i Room longitude
      //------------------------------------------------------
      const pointLat = 23.593345798726066; // Los Angeles latitude
      const pointLon = 58.401063630632045; // Los Angeles longitude

      // const pointLat = 23.59016987681035; // Los Angeles latitude
      // const pointLon = 58.381691519395154; // Los Angeles longitude


// We know that one metre is equal to 1/1000 kilometres i.e., 1 metre = .001km.
      //------------------------------------------------------
      const radius = 1; // Radius in kilometers
      const distance = PageModule.prototype.getDistanceFromLatLonInKm(centerLat, centerLon, pointLat, pointLon);

    console.log("Distance==>"+radius);
    console.log("Distance==>"+distance);


      if (distance <= radius) {
          console.log(distance+"is within"+radius+"km of center");
      } else {
        console.log(distance+"is outside"+radius+"km of center");
      }

    }

  getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2){
        const R = 6371; // Radius of the Earth in kilometers
          const dLat = PageModule.prototype.deg2rad(lat2 - lat1);
          const dLon = PageModule.prototype.deg2rad(lon2 - lon1);
          const a =
              Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(PageModule.prototype.deg2rad(lat1)) * Math.cos(PageModule.prototype.deg2rad(lat2)) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
          const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
          const d = R * c; // Distance in km
          return d;
      }

    deg2rad(deg) {
        return deg * (Math.PI / 180);
    }





// ====================
  }
  
  return PageModule;
});
