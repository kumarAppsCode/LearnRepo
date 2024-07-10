declare
begin
UPDATE FS_TRAVEL_HEADER_T
SET 
PCS_INSTANCE_NUMBER              =: p_PCS_INSTANCE_NUMBER
where TRAVEL_HEADER_ID=:p_TRAVEL_HEADER_ID;
commit;
:p_err_code:='S';
:p_message:='Record Update Successfully';
end;
