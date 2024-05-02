linkArray=====> link Array
btn_type======> Button Name
btnOffSet=====> Button OffSet [current stored value]
totalCount====> REST Total Count
hasMore=======> REST has more 

// Button Name
// FIRST
// NEXT
// CURRENT
// PREVIOUS
// onload--FIRST--0

    /**
     *
     * @param {String} arg1
     * @return {String}
     */
    fetchMoreData(linkArray, btn_type, btnOffSet, totalCount, hasMore) {
      let hasFirst_Disable = true;
      let hasPrev_Disable = true;
      let hasNext_Disable = true;
      let lfirstoffset = 0;
      let lprevoffset = 0;
      let lnextoffset = 0;
      let lcurroffset = 0;

      let lfin_firoffset = 0;
      let lfin_prevoffset = 0;
      let lfin_lnextoffset = 0;
      let lfin_lcurroffset = 0;


// console.log("==>LM=>");
// console.log("==>LM=>"+JSON.stringify(linkArray));

  linkArray.forEach(link => {
    if (link.rel === "first") {
        const offsetMatch = link.href.match(/offset=(\d+)/);
        if (offsetMatch!==null && offsetMatch[1] !== undefined) {
          hasFirst_Disable = false;
          lfirstoffset = parseInt(offsetMatch[1], 10); // offset - 0
        }
    } else if (link.rel === "prev") {
        const offsetMatch = link.href.match(/offset=(\d+)/);
        if (offsetMatch!==null && offsetMatch[1] !== undefined) {
          lprevoffset = parseInt(offsetMatch[1], 10); // prev - first
        }
    } else if (link.rel === "next") {
        const offsetMatch = link.href.match(/offset=(\d+)/);
      if (offsetMatch && offsetMatch[1] !== undefined) {
          lnextoffset = parseInt(offsetMatch[1], 10); // next - first
      }
    }
  });

// FIRST
// NEXT
// CURRENT
// PREVIOUS

    if(hasMore){
      hasNext_Disable=false;
    }
// 
    if(btn_type==="FIRST"){
      lfin_firoffset=0;
      lfin_prevoffset=0;
      lfin_lnextoffset=lnextoffset;
      lfin_lcurroffset=0;
    }

 if(btn_type==="NEXT"){
      lfin_firoffset=0;
      lfin_lnextoffset=lnextoffset;
      if(lnextoffset===0){
		lfin_lcurroffset=btnOffSet;
		lfin_prevoffset=btnOffSet-totalCount;
      }else{
		lfin_lcurroffset=lnextoffset-totalCount;
		lfin_prevoffset=lfin_lcurroffset-totalCount;
      }
      if(lfin_prevoffset>0){
        hasPrev_Disable=false;
      }
    }        

    if(btn_type==="CURRENT"){
      lfin_firoffset=0;
      lfin_lnextoffset=btnOffSet+totalCount;
      lfin_lcurroffset=btnOffSet;
      if(lfin_lcurroffset===0){
          lfin_prevoffset===0;
      }else{
          lfin_prevoffset=btnOffSet-totalCount;
      }
     
      if(lfin_prevoffset>0){
        hasPrev_Disable=false;
      }
    }

    if(btn_type==="PREVIOUS"){
      lfin_firoffset=0;
      lfin_lcurroffset=btnOffSet;
      lfin_lnextoffset=btnOffSet+totalCount;
      lfin_prevoffset=btnOffSet-totalCount;

      if(lfin_prevoffset<=0){
          hasPrev_Disable=true;
          lfin_prevoffset=0; 
      }else{
          hasPrev_Disable=false;
      }   
    }

  console.log("==>LM=>lfirstoffset==>:", lfin_firoffset);
  console.log("==>LM=>lprevoffset==>:", lfin_prevoffset);
  console.log("==>LM=>lnextoffset==>:", lfin_lnextoffset);
  console.log("==>LM=>lcurroffset==>:", lfin_lcurroffset);
  console.log("==>LM=>hasPrev_Disable==>:", hasPrev_Disable);
  console.log("==>LM=>hasNext_Disable==>:", hasNext_Disable);

  return {
    lfirstoffset: lfin_firoffset,
    lprevoffset: lfin_prevoffset,
    lnextoffset: lfin_lnextoffset,
    lcurroffset:lfin_lcurroffset,
    hasPrev_Disable: hasPrev_Disable,
    hasNext_Disable: hasNext_Disable
  };
    
    }
