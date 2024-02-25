CREATE OR REPLACE PACKAGE "FS_APPROVAL_REASSIGN_PKG" 
IS

   PROCEDURE reassign_process(
                    p_instance_number       in      varchar2
                   ,p_from_perosn_id        in      varchar2
                   ,p_to_perosn_id          in      varchar2
                   ,p_comments              in      varchar2
                   ,p_appr_level            in      varchar2
                   ,p_approval_code         in      varchar2
                   ,p_module_name           out     varchar2
                   ,p_callsubmitpackage     out     varchar2
                   ,p_appr_process          out     varchar2
                   ,p_trx_id                out     varchar2
                   ,p_action_id             out     varchar2
                   ,p_user_id               out     varchar2
                   ,p_error_code            out     varchar2
                   ,p_error_msg             out     varchar2
                   );

END fs_approval_reassign_pkg;
/


CREATE OR REPLACE PACKAGE BODY "FS_APPROVAL_REASSIGN_PKG" 
IS
   l_error_code   VARCHAR2(1) := 'S';
   l_error_msg    VARCHAR2(2000);


--Re-assign--------
--==>Re-assign in data base-->
--==>New Pending Record
--==>Terminate
--==>Submit Again
--Action id-->
--pkg--No


--
--SELECT 
----ACTION_ID 
--*
--FROM fs_approval_action_t 
--where 
--APPROVAL_PCS_INSTANCE_NUM='880b28cf-53b6-11ee-921e-4e4d3f4699d4';
--/
--
--SELECT * FROM fs_approval_action_history_t;
--
--SELECT 
--APPR_REQUEST_CODE,
--ACTION_ID, 
--TRANSACTION_ID,
--RESPONSE_USER_ID, RESPONSE_USER, RESPONSE_EMAIL_ADDRESS
--
--FROM fs_approval_action_history_new_v
--
--/
----From Address
--SELECT 
--apphis.ACTION_HISTORY_ID,
--apphis.APPR_REQUEST_CODE,
--apphis.ACTION_ID, 
--apphis.TRANSACTION_ID,
--apphis.RESPONSE_USER_ID, 
--apphis.RESPONSE_USER, 
--apphis.RESPONSE_EMAIL_ADDRESS,
--appac.APPROVAL_PCS_INSTANCE_NUM
--FROM 
--fs_approval_action_history_new_v apphis,
--fs_approval_action_t  appac
--where 
--apphis.ACTION_ID=appac.ACTION_ID
--and appac.APPROVER_LEVEL=apphis.APPR_LEVEL
--and appac.STATUS_CODE<>'A'
--and appac.APPROVAL_PCS_INSTANCE_NUM='880b28cf-53b6-11ee-921e-4e4d3f4699d4';
--
----From Address
--INSERT INTO fs_approval_action_history_t(action_history_id
--                                                    ,action_id
--                                                    ,appr_hierarchy_id
--                                                    ,appr_category_id
--                                                    ,appr_type_id
--                                                    ,appr_level
--                                                    ,action_sequence_num
--                                                    ,requester_user_id
--                                                    ,response_user_id
--                                                    ,action_type_id
--                                                    ,appr_role_id
--                                                    ,action_date
--                                                    ,action_comments
--                                                    ,created_by
--                                                    ,creation_date
--                                                    ,last_updated_by
--                                                    ,last_update_date
--                                                    ,last_update_login)
--                 VALUES (fs_approval_action_history_id_s.NEXTVAL       --action_history_id
--                        ,l_action_id                                   --action_id
--                        ,rec_appr.appr_hierarchy_id                    --appr_hierarchy_id
--                        ,rec_appr.appr_category_id                     --appr_category_id
--                        ,rec_appr.appr_type_id                         --appr_type_id
--                        ,rec_appr.appr_level                           --appr_level
--                        ,l_action_sequence_num                         --action_sequence_num
--                        ,l_requester_user_id                           --requester_user_id
--                        ,rec_appr.appr_user_id                        --response_user_id
--                        ,l_action_type_id                              --action_type_id
--                        ,rec_appr.appr_role_id
--                        ,NULL                                         --action_date
--                        ,NULL                                         --action_comments
--                        ,p_user_id                                    --created_by
--                        ,SYSDATE                                      --creation_date
--                        ,p_user_id                                    --last_updated_by
--                        ,SYSDATE                                      --last_update_date
--                        ,p_user_id                                    --last_update_login
--                                  );
----
----
--         --To find out next approver
--         BEGIN
--              SELECT faah.appr_level
--                    ,faah.appr_category_code
--                    ,LISTAGG(faah.response_user_id
--                            ,',')
--                        approver_user_id
--                    ,LISTAGG(faah.response_email_address
--                            ,',')
--                        approver_email_address
--                INTO l_approver_level
--                    ,l_approver_category_code
--                    ,l_approver_user_id
--                    ,l_approver_email_address
--                FROM fs_approval_action_history_v faah
--               WHERE faah.action_id = rec_action.action_id
--                 AND faah.appr_level = (SELECT MIN(appr_level)
--                                          FROM fs_approval_action_history_t
--                                         WHERE action_id = rec_action.action_id
--                                           AND appr_level > rec_action.approver_level)
--            GROUP BY faah.appr_level
--                    ,faah.appr_category_code;
--         EXCEPTION
--            WHEN NO_DATA_FOUND THEN
--               l_approver_level := NULL;
--               l_approver_category_code := NULL;
--               l_approver_user_id := NULL;
--               l_approver_email_address := NULL;
--               l_final_approver := 'Y';
--            WHEN OTHERS THEN
--               l_error_code := 'E';
--               l_error_msg := 'API Error';
--         END;
----         
----
--         UPDATE fs_approval_action_history_t
--            SET action_type_id = fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','NTY')
--               ,action_date  = SYSDATE
--               ,action_comments = NVL(p_comments, 'FYI')
--          WHERE action_id = rec_action.action_id
--            AND appr_level = rec_action.approver_level;
--         commit;
--         UPDATE fs_approval_action_t
--            SET approver_user_id = l_approver_user_id
--               ,approver_email_id = l_approver_email_address
--               ,approver_level = l_approver_level
--               ,approval_category_code = l_approver_category_code
--          --,status_code              = CASE WHEN l_final_approver = 'Y' THEN 'A' ELSE 'O' END
--          WHERE action_id = rec_action.action_id;
--          commit;
----          
----
--
   PROCEDURE reassign_process(
                    p_instance_number       in      varchar2
                   ,p_from_perosn_id        in      varchar2
                   ,p_to_perosn_id          in      varchar2
                   ,p_comments              in      varchar2
                   ,p_appr_level            in      varchar2
                   ,p_approval_code         in      varchar2
                   ,p_module_name           out     varchar2
                   ,p_callsubmitpackage     out     varchar2
                   ,p_appr_process          out     varchar2
                   ,p_trx_id                out     varchar2
                   ,p_action_id             out     varchar2
                   ,p_user_id               out     varchar2
                   ,p_error_code            out     varchar2
                   ,p_error_msg             out     varchar2
                   )
is

l_action_id             fs_approval_action_t.ACTION_ID%TYPE;
l_transaction_id        fs_approval_action_t.TRANSACTION_ID%TYPE;
l_requester_user_id     fs_approval_action_t.REQUESTER_USER_ID%TYPE;
l_requester_email_id    fs_approval_action_t.REQUESTER_EMAIL_ID%TYPE;
l_action_history_id     fs_approval_action_history_t.ACTION_HISTORY_ID%TYPE;
l_response_email_address   varchar2(2000); 

l_new_approver_level           NUMBER;
l_new_approver_category_code    VARCHAR2(30);
l_new_approver_user_id         VARCHAR2(2000);
l_new_approver_email_address   VARCHAR2(2000);
l_new_appr_request_code         VARCHAR2(240);
l_module_name                   VARCHAR2(240);


cursor approval_reassign_history(
            ll_approval_history_id number, 
            ll_action_id number, 
            ll_app_level number,
            ll_app_user_id number)
is 
SELECT * FROM fs_approval_action_history_t
where 
1=1
and rownum=1
and ACTION_HISTORY_ID=ll_approval_history_id
and ACTION_ID=ll_action_id
and APPR_LEVEL=ll_app_level
and RESPONSE_USER_ID=ll_app_user_id;



BEGIN
--Get Action Detail
begin
    SELECT 
    ACTION_ID,
    TRANSACTION_ID,
    REQUESTER_USER_ID, 
    REQUESTER_EMAIL_ID
    into 
    l_action_id,
    l_transaction_id,
    l_requester_user_id, 
    l_requester_email_id
    FROM fs_approval_action_t 
    where 
    APPROVAL_PCS_INSTANCE_NUM=p_instance_number
    and APPROVER_LEVEL=p_APPR_LEVEL;
exception when others  then 
    l_action_id :=null;
    l_transaction_id:=null;
    l_requester_user_id:=null; 
    l_requester_email_id:=null;
end;
--Get Approval history
begin
    SELECT 
    ACTION_HISTORY_ID,
    RESPONSE_EMAIL_ADDRESS
    into 
    l_action_history_id,
    l_response_email_address
    FROM fs_approval_action_history_new_v
    where 
    ACTION_ID=l_action_id
    and APPR_LEVEL=p_APPR_LEVEL
    and RESPONSE_USER_ID=p_from_perosn_id;
exception when others then 
l_action_history_id:=null;
l_response_email_address:=null;
end;




if(l_action_history_id is not null) then 
--update Status as re-assign
update fs_approval_action_history_t
set
--ACTION_DATE=TO_TIMESTAMP(trim(substr(current_timestamp at time zone 'Asia/Muscat' , 0,27))),
ACTION_DATE=SYSTIMESTAMP,
ACTION_COMMENTS=p_comments,
--APPROVER_ACTION_DATE=TO_TIMESTAMP(trim(substr(current_timestamp at time zone 'Asia/Muscat' , 0,27))),
--LAST_UPDATE_DATE=TO_TIMESTAMP(trim(substr(current_timestamp at time zone 'Asia/Muscat' , 0,27))),
APPROVER_ACTION_DATE=SYSTIMESTAMP,
LAST_UPDATE_DATE=SYSTIMESTAMP,
APPROVER_ACTION_COMMENTS=p_comments,
APPROVER_EMAIL_ID=l_response_email_address,
APPROVER_USER_ID=null,
APPROVER_ACTION_CODE='REASSIGN',
APPROVER_ACTION_TYPE_ID=(SELECT LOOKUP_VALUE_ID FROM fs_lookup_values_v where 
                                    rownum=1
                                    and LOOKUP_TYPE_NAME='APPROVAL_ACTION'
                                    and LOOKUP_VALUE_NAME='REASSIGN'),
ACTION_TYPE_ID=(SELECT LOOKUP_VALUE_ID FROM fs_lookup_values_v where 
                                    rownum=1
                                    and LOOKUP_TYPE_NAME='APPROVAL_ACTION'
                                    and LOOKUP_VALUE_NAME='REASSIGN')
where 
1=1
and ACTION_HISTORY_ID=l_action_history_id
and ACTION_ID=l_action_id
and APPR_LEVEL=p_APPR_LEVEL
and RESPONSE_USER_ID=p_from_perosn_id;
commit;
--insert new line for re-assign user
for c1 in approval_reassign_history(l_action_history_id,l_action_id,p_APPR_LEVEL,p_from_perosn_id)
loop
INSERT INTO fs_approval_action_history_t (
    action_history_id,
    action_id,
    appr_hierarchy_id,
    appr_category_id,
    appr_type_id,
    appr_level,
    action_sequence_num,
    requester_user_id,
    response_user_id,
    action_type_id,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    appr_role_id
) VALUES (
    FS_APPROVAL_ACTION_HISTORY_ID_S.nextval,
    c1.action_id,
    c1.appr_hierarchy_id,
    c1.appr_category_id,
    c1.appr_type_id,
    c1.appr_level,
    c1.action_sequence_num,
    p_from_perosn_id,
    p_to_perosn_id,
    FS_VALIDATION_UTILS.get_lookup_value_id('APPROVAL_ACTION','PENDING'),
    p_from_perosn_id,
    SYSTIMESTAMP,
--  TO_TIMESTAMP(trim(substr(current_timestamp at time zone 'Asia/Muscat' , 0,27))),
    p_from_perosn_id,
    SYSTIMESTAMP,
--  TO_TIMESTAMP(trim(substr(current_timestamp at time zone 'Asia/Muscat' , 0,27))),
    p_from_perosn_id,
    c1.appr_role_id
);
commit;
end loop;
--group approval
BEGIN
    SELECT faah.appr_level 
    ,faah.appr_category_code
    ,LISTAGG(faah.response_user_id,',') as approver_user_id
    ,LISTAGG(faah.response_email_address,',') as approver_email_address
    ,faah.APPR_REQUEST_CODE
    ,faah.MODULE_NAME
    INTO 
     l_new_approver_level
    ,l_new_approver_category_code
    ,l_new_approver_user_id
    ,l_new_approver_email_address
    ,l_new_appr_request_code
    ,l_module_name
    FROM fs_approval_action_history_new_v faah 
    WHERE 
    faah.action_id = l_action_id
    and faah.TRANSACTION_ID=l_transaction_id
    and faah.APPR_LEVEL=p_APPR_LEVEL
    and faah.ACTION_DATE is null
    group by faah.appr_level, faah.appr_category_code, faah.APPR_REQUEST_CODE,faah.APPR_REQUEST_CODE,faah.MODULE_NAME;
    commit;
EXCEPTION
WHEN NO_DATA_FOUND THEN
l_new_approver_level := NULL;
l_new_approver_category_code := NULL;
l_new_approver_user_id := NULL;
l_new_approver_email_address := NULL;
WHEN OTHERS THEN
l_error_code := 'E';
l_error_msg := 'API Error';
END;
---update approval action table
UPDATE fs_approval_action_t
SET approver_user_id = l_new_approver_user_id
,approver_email_id = l_new_approver_email_address
,approver_level = l_new_approver_level
,approval_category_code = l_new_approver_category_code
,status_code  = 'O'
WHERE action_id = l_action_id;
commit;

p_module_name:=l_module_name;
P_callSubmitPackage:='NO';
p_APPR_PROCESS:=l_new_appr_request_code;
p_TRX_ID:=l_transaction_id;
p_ACTION_ID:=l_action_id;
p_USER_ID:=l_requester_user_id;
p_error_code:='S';
p_error_msg:='Success';

else
p_error_code:='E';
p_error_msg:='History of Approvals Detail Empty. To contact the admissions officer';
end if;






END reassign_process;

END fs_approval_reassign_pkg;
/
