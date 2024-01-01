    /**
     * @param {Object} context
     * @param {Object} params
     * @param {any} params.para_amt 
     * @param {any} params.para_no_of_days 
     */
    async amountCalFun(context, { para_amt, para_no_of_days }) {
      const { $page, $flow, $application } = context;

      let allowanceAmount = 0;
      allowanceAmount = para_no_of_days * Number(para_amt);
      console.log("Allowance Amount <br>" + allowanceAmount);
      
      return Number(Math.round(allowanceAmount)) ;      

    }
