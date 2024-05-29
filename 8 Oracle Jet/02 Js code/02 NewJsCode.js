Oracle Jet Life Cycle

define(['../accUtils'],
 function(accUtils) {
    function RoadViewModel() {

      this.connected = () => {
        accUtils.announce('Road page loaded.');
        document.title = "Road";
      };

      this.disconnected = () => {
      };

      this.transitionCompleted = () => {
      };
    }

    return RoadViewModel;
  }
);
