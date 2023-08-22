declare
lperson_count number;
BEGIN
    begin
        SELECT 
        count(*) into lperson_count
        FROM person_t 
        where 
        rownum=1
        and upper(EMAIL_ADDRESS)=upper(:p_idcs_email_id);
    exception when no_data_found then 
    lperson_count:=0;
    end;

if(lperson_count!=0) then 
--emailid based user update
update action_history_t 
set 
APPROVER_ACTION_DATE=sysdate, 
APPROVER_ACTION_COMMENTS=:p_comment, 
APPROVER_EMAIL_ID=:p_idcs_email_id, 
APPROVER_USER_ID=:p_idcs_user_id
where 
1=1
and ACTION_ID in (SELECT ACTION_ID FROM fs_approval_action_t where transaction_id=:p_transaction_id)
and APPR_LEVEL in (SELECT APPROVER_LEVEL FROM fs_approval_action_t where transaction_id=:p_transaction_id)
and RESPONSE_USER_ID in
(SELECT PERSON_ID FROM fs_person_stg_t 
where 
rownum=1
and upper(EMAIL_ADDRESS)=upper(:p_idcs_email_id));
commit;

else
--email id not found in so update in all level
update fs_action_history_t 
set 
APPROVER_ACTION_DATE=sysdate, 
APPROVER_ACTION_COMMENTS=:p_comment, 
APPROVER_EMAIL_ID=:p_idcs_email_id, 
APPROVER_USER_ID=:p_idcs_user_id
where 
1=1
and ACTION_ID in (SELECT ACTION_ID FROM fs_approval_action_t where transaction_id=:p_transaction_id)
and APPR_LEVEL in (SELECT APPROVER_LEVEL FROM fs_approval_action_t where transaction_id=:p_transaction_id);
commit;
end if;


:p_status:='S';
:p_message:='Record Updated';
END;
