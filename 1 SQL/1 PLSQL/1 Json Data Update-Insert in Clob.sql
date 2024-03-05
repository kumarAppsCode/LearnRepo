UPDATE j_purchaseorder
SET
    po_document = JSON_TRANSFORM(po_document, SET '$.lastUpdated' = systimestamp);
    
    
SELECT * FROM fs_travel_booking_t where TRAVEL_BOOKING_ID=76055;

--Update Json Date 
update fs_travel_booking_t
set 
REQUEST_DATA=JSON_TRANSFORM(REQUEST_DATA, SET '$.arriving_country' = 'Oman 123')
where TRAVEL_BOOKING_ID=76055;

--Insert Json Date 
update fs_travel_booking_t
set 
REQUEST_DATA=JSON_TRANSFORM(REQUEST_DATA, INSERT '$.testing' = 'Oman 123')
where TRAVEL_BOOKING_ID=76055;

--Remove field
update fs_travel_booking_t
set 
REQUEST_DATA=JSON_TRANSFORM(REQUEST_DATA, remove '$.testing')
where TRAVEL_BOOKING_ID=76055;
