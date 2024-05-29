SELECT 
distinct
INSTANCE_ID,
INTERFACE_NAME as INTERFACE_NAME_CODE,
INTERFACE_NAME as INTERFACE_NAME_NAME,
INTERFACE_ID as INTERFACE_ID_CODE,
INTERFACE_ID as INTERFACE_ID_NAME
FROM xxzlr_log_msgs_tbl
where 
1=1
  AND
 ( 
   INSTANCE_ID = decode(:pinstanceId,      'undefined', instance_id,
                                         'Search',    instance_id,
                                          NULL,       instance_id,
                                                      :pinstanceId) 
 
 and
(
    (UPPER (INTERFACE_ID) LIKE '%' || UPPER (:pinterfaceId) || '%' OR :pinterfaceId IS NULL) OR 
    UPPER(:pinterfaceId)= UPPER('Search') OR UPPER(:pinterfaceId)= UPPER('undefined') 
) 
 and 
(
    (UPPER (INTERFACE_NAME) LIKE '%' || UPPER (:pinterfaceName) || '%' OR :pinterfaceName IS NULL) OR 
    UPPER(:pinterfaceName)= UPPER('Search') OR UPPER(:pinterfaceName)= UPPER('undefined') 
)

)                                                      
