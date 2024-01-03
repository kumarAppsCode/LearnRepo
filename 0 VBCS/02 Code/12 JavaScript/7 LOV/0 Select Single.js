   lovBasedValue  (index, new_rating_name,new_rating_code,new_goal_rating) {     
      document.getElementById('new_rating_name' + index).value = new_rating_name;  
      document.getElementById('new_rating_code' + index).value = new_rating_code; 
      document.getElementById('new_goal_rating' + index).value = new_goal_rating;  
    };

// 

   <div id="sampleDemo" style="" class="demo-padding demo-container">
  <div id="componentDemoContent" style="width: 1px; min-width: 100%;">
    <div id="mainContent">
<oj-table scroll-policy="loadMoreOnScroll" class="oj-sm-width-full oj-bg-body oj-search-table" display="grid"
  data="[[ $variables.normalization_adp ]]"
  columns='{{ ($application.variables.appType==="EMP")?$variables.normal_column:($application.variables.appType==="IT")?$variables.Admin_column:$variables.normal_column }}' 
   >
    <template slot="newrating">
  <!-- <oj-select-single label-hint="Select (Single)"  value="[[ $current.row.new_rating_name ]]"></oj-select-single> -->
  <oj-bind-if test='[[ ($current.row.status=="Draft")?false:true ]]'>  
 <oj-input-text value="[[ $current.row.new_rating_name ]]" class="oj-flex-item oj-sm-12 oj-md-6"
   :id="[['new_rating_name'+$current.index]]"></oj-input-text>
  </oj-bind-if>
   <oj-bind-if test='[[ ($current.row.status=="Draft")?true:false ]]'>  
   <!-- <oj-combobox-one :id="[[ 'new_rating_name'+$current.index ]]"
     value="[[ $current.row.new_rating_name ]]"
     maximum-result-count="2000" options-keys.value="new_rating_name" options-keys.label="new_rating_name"
     on-value-changed="[[$listeners.newRatingNameValue2]]" options="[[$variables.findbyPerformanceratingListSDP2]]" >
      </oj-combobox-one> -->
  <oj-select-single item-text="new_rating_name" :id="[[ 'new_rating_level_id'+$current.index ]]"
    value="{{ $current.row.new_rating_level_id }}" data="[[$variables.findbyPerformanceratingListSDP5]]"
    on-value-item-changed="[[$listeners.newRatingNameValueItem]]" ></oj-select-single>
<!-- <oj-combobox-one :id="[[ 'new_rating_level_id'+$current.index ]]" value="[[ $current.row.new_rating_level_id ]]"
  maximum-result-count="2000" options-keys.value="new_rating_level_id" options-keys.label="new_rating_name"
  on-value-changed="[[$listeners.newRatingNameValue2]]" options="[[$variables.findbyPerformanceratingListSDP4]]" >
      </oj-combobox-one> -->
   
   </oj-bind-if>    
   <oj-input-text value="[[ $current.row.new_rating_name ]]" class="oj-flex-item oj-sm-12 oj-md-6"
   :id="[['new_rating_name'+$current.index]]"></oj-input-text>
    <oj-input-text value="[[ $current.row.new_rating_code ]]" class="oj-flex-item oj-sm-12 oj-md-6"
   :id="[['new_rating_code'+$current.index]]"></oj-input-text>
    <oj-input-text value="[[ $current.row.new_goal_rating ]]" class="oj-flex-item oj-sm-12 oj-md-6"
   :id="[['new_goal_rating'+$current.index]]"></oj-input-text> 
       <!-- <oj-input-text value="[[ $current.row.new_rating_level_id ]]" class="oj-flex-item oj-sm-12 oj-md-6"
   :id="[['new_rating_level_id_temp'+$current.index]]"></oj-input-text>  -->
    </template>


     <!-- <template slot="lovnewvalue">
   <oj-input-text value="[[ $current.row.new_rating_name ]]" class="oj-flex-item oj-sm-12 oj-md-6"
   :id="[['new_rating_name'+$current.index]]"></oj-input-text>
    <oj-input-text value="[[ $current.row.new_rating_code ]]" class="oj-flex-item oj-sm-12 oj-md-6"
   :id="[['new_rating_code'+$current.index]]"></oj-input-text>
    <oj-input-text value="[[ $current.row.new_goal_rating ]]" class="oj-flex-item oj-sm-12 oj-md-6"
   :id="[['new_goal_rating'+$current.index]]"></oj-input-text>
  </template> -->
   <!-- <oj-paging-control slot="bottom"  page-size="15"></oj-paging-control> -->
  
   </oj-table>
    </div>
  </div>
</div>
