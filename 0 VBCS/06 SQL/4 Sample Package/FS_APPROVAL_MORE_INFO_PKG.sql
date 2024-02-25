CREATE OR REPLACE PACKAGE FS_APPROVAL_MORE_INFO_PKG 
IS

  PROCEDURE more_info_process (
        p_moreinfo_type             IN VARCHAR2,
        p_moreinfo_user_email_id    IN VARCHAR2,
        p_moreinfo_user_person_id   IN VARCHAR2,
        p_type                      IN VARCHAR2,
        p_module_name               IN VARCHAR2,
        p_more_info_id              IN VARCHAR2,
        p_transaction_id            IN VARCHAR2,
        p_transaction_number        IN VARCHAR2,
        p_login_user                IN VARCHAR2,
        p_comment                   IN VARCHAR2,
        p_action_id                 OUT VARCHAR2,
        p_callsubmitpackage         OUT VARCHAR2,
        p_appr_process              out varchar2,
        p_user_id                   out varchar2,
        p_error_code                OUT VARCHAR2,
        p_error_msg                 OUT VARCHAR2

    );

END FS_APPROVAL_MORE_INFO_PKG;

/


CREATE OR REPLACE PACKAGE BODY FS_APPROVAL_MORE_INFO_PKG 
IS
   l_error_code   VARCHAR2(1) := 'S';
   l_error_msg    VARCHAR2(2000);


   PROCEDURE more_info_process (
        p_moreinfo_type             IN VARCHAR2,
        p_moreinfo_user_email_id    IN VARCHAR2,
        p_moreinfo_user_person_id   IN VARCHAR2,
        p_type                      IN VARCHAR2,
        p_module_name               IN VARCHAR2,
        p_more_info_id              IN VARCHAR2,
        p_transaction_id            IN VARCHAR2,
        p_transaction_number        IN VARCHAR2,
        p_login_user                IN VARCHAR2,
        p_comment                   IN VARCHAR2,
        p_action_id                 OUT VARCHAR2,
        p_callsubmitpackage         OUT VARCHAR2,
        p_appr_process              out varchar2,
        p_user_id                   out varchar2,
        p_error_code                OUT VARCHAR2,
        p_error_msg                 OUT VARCHAR2
    )
is

l_from_person_id        number;    
l_appr_request_code     varchar2(240);
lSTATUS                 VARCHAR2(120);
l_action_history_id     number;
l_action_id             number;
l_appr_level            number;


l_new_approver_level           NUMBER;
l_new_approver_category_code    VARCHAR2(30);
l_new_approver_user_id         VARCHAR2(2000);
l_new_approver_email_address   VARCHAR2(2000);
l_new_appr_request_code         VARCHAR2(240);
l_module_name                   VARCHAR2(240);

l_appr_process_name                   VARCHAR2(240);
l_requester_user_id fs_approval_action_t.REQUESTER_USER_ID%TYPE;
l_requester_email_id fs_approval_action_t.requester_email_id%TYPE;

l_moreinfo_user_person_id number;

l_moreinfo_user_emailid varchar2(240);

lo_moreinfo_id number;
lo_moreinfo_name varchar2(240);
ll_moreinfo_type  varchar2(240);


cursor approval_moreinfo_history(
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


cursor approval_moreinfo_req_history(
ll_app_user_id number, 
ll_action_id number, 
ll_appr_level number
)
is 
SELECT * FROM fs_approval_action_history_t
where 
1=1
and rownum=1
--and ACTION_TYPE_ID=FS_VALIDATION_UTILS.get_lookup_value_id('APPROVAL_ACTION','APPROVER_MORE_INFO')
--and APPROVER_ACTION_TYPE_ID=FS_VALIDATION_UTILS.get_lookup_value_id('APPROVAL_ACTION','APPROVER_MORE_INFO_REQ')
and APPROVER_ACTION_TYPE_ID=FS_VALIDATION_UTILS.get_lookup_value_id('APPROVAL_ACTION',upper(p_moreinfo_type)||'_REQ')
and RESPONSE_USER_ID=ll_app_user_id
and ACTION_ID=ll_action_id
and APPR_LEVEL=ll_appr_level;


BEGIN
--------Get From Person Id [Response userid]--------
    begin
        SELECT 
        PERSON_ID 
        into 
        l_from_person_id
        FROM fs_person_stg_t 
        where 
        rownum=1
        and upper(EMAIL_ADDRESS)=upper(p_login_user);
    exception when others then
        l_from_person_id:=null;
    end;
-----------------------------------------------
--Get the approval history id and module name and action id
begin
    SELECT 
    APPR_REQUEST_CODE,
    ACTION_HISTORY_ID,
    ACTION_ID,
    APPR_LEVEL
    into 
    l_appr_request_code,
    l_action_history_id,
    l_action_id,
    l_appr_level
    FROM fs_approval_action_history_new_v
    where 
   -- 1=1
    rownum=1
    AND ACTION_ID IN (SELECT max(ACTION_ID) FROM fs_approval_action_t where 1=1 AND STATUS_CODE='O' AND APPROVER_EMAIL_ID IS NOT NULL AND transaction_id=p_transaction_id)
    and upper(module_name)=upper(p_module_name)
    and RESPONSE_USER_ID=l_from_person_id
    and TRANSACTION_ID=p_transaction_id
    and APPR_LEVEL in (SELECT APPROVER_LEVEL FROM fs_approval_action_t where STATUS_CODE='O' and TRANSACTION_ID=p_transaction_id);
exception when others then 
    l_appr_request_code:=NULL;
    l_action_history_id:=null;
    l_action_id:=null;
end;

begin
SELECT REQUESTER_USER_ID, requester_email_id 
into l_requester_user_id, l_requester_email_id
FROM fs_approval_action_t 
where 
1=1
and rownum=1
and STATUS_CODE='O' 
and TRANSACTION_ID=p_transaction_id;
exception when others then 
l_requester_user_id:=null;
end;


-----------------------------------------------
if(l_from_person_id is not null and l_action_history_id is not null and l_requester_user_id is not null)then 
DBMS_OUTPUT.PUT_LINE('STAGE!;');
if(upper(p_type)='CREATE')then
-------------More info Record insert
            INSERT INTO fs_approval_more_info_t (
                    more_info_id,
                    transaction_id,
                    transaction_number,
                    requestor_date,
                    requestor_person_id,
                    requestor_email_id,
                    requestor_question,
                    status,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    last_update_login,
                    MORE_INFO_TYPE
                ) VALUES (
                    MORE_INFO_ID_S.nextval,
                    p_transaction_id,
                    p_transaction_number,
                    SYSTIMESTAMP,
                    l_from_person_id,
                    p_login_user,
                    p_comment,
                    'D',
                    p_login_user,
                    SYSTIMESTAMP,
                    p_login_user,
                    SYSTIMESTAMP,
                    p_login_user,
                    p_moreinfo_type
                );
                commit;
--------------------------------------------
--if(upper(p_moreinfo_type)='EMP_MORE_INFO') then 
IF(upper(p_moreinfo_type)=upper('EMP_MORE_INFO')) then 
    l_moreinfo_user_person_id:=l_requester_user_id;
    l_moreinfo_user_emailid:=l_requester_email_id;
    lo_moreinfo_id:=FS_VALIDATION_UTILS.get_lookup_value_id('APPROVAL_ACTION','EMP_MORE_INFO_REQ');
    lo_moreinfo_name:=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION','EMP_MORE_INFO_REQ');
    ll_moreinfo_type:='EMP_MORE_INFO_REQ';
else
l_moreinfo_user_person_id:=p_moreinfo_user_person_id;
l_moreinfo_user_emailid:=p_moreinfo_user_email_id;
if(p_moreinfo_user_person_id=0) then 
    begin
            SELECT 
            distinct PERSON_ID 
            into
            l_moreinfo_user_person_id        
            FROM fs_person_stg_t 
            where 
            rownum=1
            and upper(EMAIL_ADDRESS)=upper(p_moreinfo_user_email_id);
    exception when others then
        l_moreinfo_user_person_id:=null;
    end;
end if;

lo_moreinfo_id:=FS_VALIDATION_UTILS.get_lookup_value_id('APPROVAL_ACTION','APPROVER_MORE_INFO_REQ');
lo_moreinfo_name:=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION','APPROVER_MORE_INFO_REQ');
ll_moreinfo_type:='APPROVER_MORE_INFO_REQ';
end if;
--------------------------------------------
            --insert new line for moreinfo user
       for c1 in approval_moreinfo_history(l_action_history_id,l_action_id,l_appr_level,l_from_person_id)
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
                    appr_role_id,
                    ACTION_COMMENTS,
                    APPROVER_ACTION_DATE,
                    APPROVER_EMAIL_ID,
                    APPROVER_ACTION_CODE,
                    APPROVER_ACTION_TYPE_ID,
                    APPROVER_ACTION_COMMENTS
                ) VALUES (
                    FS_APPROVAL_ACTION_HISTORY_ID_S.nextval,
                    c1.action_id,
                    c1.appr_hierarchy_id,
                    c1.appr_category_id,
                    c1.appr_type_id,
                    c1.appr_level,
                    c1.action_sequence_num,
                    l_from_person_id,
                    l_moreinfo_user_person_id,
                    lo_moreinfo_id,
                    l_from_person_id,
                    SYSTIMESTAMP,
                    l_from_person_id,
                    SYSTIMESTAMP,
                    l_from_person_id,
                    c1.appr_role_id,
                    lo_moreinfo_name,
                    null, --SYSTIMESTAMP
                    l_moreinfo_user_emailid, --p_login_user,
                    'PENDING', --ll_moreinfo_type,
                    lo_moreinfo_id,
                    lo_moreinfo_name
                );
                commit;
            --action done by approver                 
            update fs_approval_action_history_t
            set APPROVER_EMAIL_ID=p_login_user,
            APPROVER_ACTION_COMMENTS='More info Request Pending',
            APPROVER_ACTION_CODE=ll_moreinfo_type,
            APPROVER_ACTION_DATE=SYSTIMESTAMP
            where ACTION_HISTORY_ID=l_action_history_id;
            commit;
                
         end loop;      
    ---group approval                
IF(upper(p_moreinfo_type)=upper('APPROVER_MORE_INFO')) then 
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
					and faah.APPROVER_ACTION_CODE='PENDING'
                    and faah.APPROVER_ACTION_DATE is null
                    and faah.TRANSACTION_ID=p_transaction_id
					and faah.APPR_LEVEL=l_appr_level
					and faah.ACTION_DATE is null
					group by faah.appr_level, faah.appr_category_code, faah.APPR_REQUEST_CODE,faah.APPR_REQUEST_CODE,faah.MODULE_NAME;
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

            sys.dbms_session.sleep(5);
        ---update approval action table
            UPDATE fs_approval_action_t
            SET approver_user_id = l_new_approver_user_id
            ,approver_email_id = l_new_approver_email_address
            ,status_code  = 'O'
            WHERE action_id = l_action_id;
            commit;
END IF;

--Transaction table status update
if(upper(p_module_name))=upper('TRAVEL_REQUEST')then 
    update fs_travel_header_t
    set TRAVEL_STATUS_ID=FS_VALIDATION_UTILS.get_lookup_value_id('APPROVAL_ACTION',p_moreinfo_type),
    STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION',p_moreinfo_type),
    LAST_UPDATE_DATE=systimestamp,
    LAST_UPDATE_LOGIN=p_login_user
    where
    TRAVEL_HEADER_ID=p_transaction_id;
    COMMIT;
---overtime table--
elsif(upper(p_module_name))=upper('OVER_TIME_REQUEST') then 
    update fs_over_time_hdr_t
    set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION',p_moreinfo_type),
    LAST_UPDATE_DATE=systimestamp,
    LAST_UPDATE_LOGIN=p_login_user
    where OVER_TIME_HDR_ID=p_transaction_id;
    commit;
elsif(upper(p_module_name))=upper('SITE_OVERTIME_REQUEST') then 
    update fs_over_time_hdr_t
    set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION',p_moreinfo_type),
    LAST_UPDATE_DATE=systimestamp,
    LAST_UPDATE_LOGIN=p_login_user
    where OVER_TIME_HDR_ID=p_transaction_id;
    commit;
--Selfservice
elsif(upper(p_module_name))=upper('SELF_SERVICE') then 
    update fs_request_details
    set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION',p_moreinfo_type),
    LAST_UPDATE_DATE=systimestamp,
    LAST_UPDATE_LOGIN=p_login_user
    where REQUEST_ID=p_transaction_id;
    commit;
    --voluntary
    
    elsif(upper(p_module_name))=upper('VOLUNTARY_EXIT') then 
    update fs_request_details
    set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION',p_moreinfo_type),
    LAST_UPDATE_DATE=systimestamp,
    LAST_UPDATE_LOGIN=p_login_user
    where REQUEST_ID=p_transaction_id;
    commit;
    
    
    --shutdown and emergency
    
    elsif(upper(p_module_name))=upper('SHUTDOWN_AND_EMERGENCY') then 
    update fs_request_details
    set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION',p_moreinfo_type),
    LAST_UPDATE_DATE=systimestamp,
    LAST_UPDATE_LOGIN=p_login_user
    where REQUEST_ID=p_transaction_id;
    commit;
    
    elsif(upper(p_module_name))=upper('FOOD_REQUEST') then 
    update fs_request_details
    set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION',p_moreinfo_type),
    LAST_UPDATE_DATE=systimestamp,
    LAST_UPDATE_LOGIN=p_login_user
    where REQUEST_ID=p_transaction_id;
    commit;
    
    
     elsif(upper(p_module_name))=upper('MOVEMENT_FORM') then 
    update fs_request_details
    set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION',p_moreinfo_type),
    LAST_UPDATE_DATE=systimestamp,
    LAST_UPDATE_LOGIN=p_login_user
    where REQUEST_ID=p_transaction_id;
    commit;
       elsif(upper(p_module_name))=upper('JOB_ROTATION') then 
    update fs_request_details
    set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION',p_moreinfo_type),
    LAST_UPDATE_DATE=systimestamp,
    LAST_UPDATE_LOGIN=p_login_user
    where REQUEST_ID=p_transaction_id;
    commit;
elsif(upper(p_module_name))=upper('LEARNING_REQUEST') then 
    update fs_Learning_module_hdr_t
    set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION',p_moreinfo_type),
    LAST_UPDATE_DATE=systimestamp,
    LAST_UPDATE_LOGIN=p_login_user
    where LEARNING_MODULE_HDR_ID=p_transaction_id;
    commit;
end if;
----Mail
    if(upper(p_moreinfo_type)=upper('APPROVER_MORE_INFO')) then 
        begin 
            FS_MAIL_NOTIFICATION_PKG.REQUEST_DETAIL_MAIL(l_appr_request_code,p_transaction_id,'MORE_INFO',lSTATUS);
        end; 
    elsif(upper(p_moreinfo_type)=upper('EMP_MORE_INFO')) then 
        begin 
            FS_MAIL_NOTIFICATION_PKG.REQUEST_DETAIL_MAIL(l_appr_request_code,p_transaction_id,'MORE_INFO',lSTATUS);
        end;         
    end if;
else
--update request
            update fs_approval_more_info_t
            set 
             response_date=systimestamp
            ,response_person_id=l_from_person_id
            ,response_email_id=p_login_user
            ,response_question=p_comment
            ,status='C'
            ,last_updated_by=p_login_user
            ,last_update_date=systimestamp
            ,last_update_login=p_login_user
            where 
            more_info_id=p_more_info_id
            and transaction_id=p_transaction_id
            and transaction_number=p_transaction_number;
            commit;
-----------------------------------------------
--MORE INFO PENDING CHANGE THE CODE
UPDATE fs_approval_action_history_t
SET APPROVER_ACTION_CODE=upper(p_moreinfo_type)||'_REQ',
APPROVER_ACTION_DATE=systimestamp --20 dec
WHERE 
APPROVER_ACTION_CODE='PENDING'
AND RESPONSE_USER_ID=l_from_person_id
AND l_action_id=ACTION_ID
AND APPR_LEVEL=l_appr_level;
COMMIT;
--MAIN TRAnsaction update
UPDATE fs_approval_action_history_t
SET 
APPROVER_ACTION_COMMENTS=NULL,
APPROVER_ACTION_CODE=NULL
WHERE 
APPROVER_ACTION_COMMENTS='More info Request Pending'
AND l_action_id=ACTION_ID
AND APPR_LEVEL=l_appr_level;
COMMIT;
--Get Approval history id
--Get the approval history id and module name and action id

--------------------------------------------
--DBMS_OUTPUT.PUT_LINE('Loop check-1'||l_from_person_id);
--DBMS_OUTPUT.PUT_LINE('Loop check-2'||l_action_id);
--DBMS_OUTPUT.PUT_LINE('Loop check-3'||l_appr_level);

IF(upper(p_moreinfo_type)=upper('EMP_MORE_INFO')) then 
l_moreinfo_user_person_id:=l_requester_user_id;
lo_moreinfo_id:=FS_VALIDATION_UTILS.get_lookup_value_id('APPROVAL_ACTION','EMP_MORE_INFO_COM');
lo_moreinfo_name:=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION','EMP_MORE_INFO_COM');
ll_moreinfo_type:='EMP_MORE_INFO_COM';
else
l_moreinfo_user_person_id:=p_moreinfo_user_person_id;
lo_moreinfo_id:=FS_VALIDATION_UTILS.get_lookup_value_id('APPROVAL_ACTION','APPROVER_MORE_INFO_COM');
lo_moreinfo_name:=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION','APPROVER_MORE_INFO_COM');
ll_moreinfo_type:='APPROVER_MORE_INFO_COM';
end if;

for c2 in approval_moreinfo_req_history(l_from_person_id, l_action_id, l_appr_level)
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
    ACTION_DATE,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    appr_role_id,
    ACTION_COMMENTS,
    APPROVER_ACTION_DATE,
    APPROVER_EMAIL_ID,
    APPROVER_ACTION_CODE,
    APPROVER_ACTION_TYPE_ID,
    APPROVER_ACTION_COMMENTS
) VALUES (
    FS_APPROVAL_ACTION_HISTORY_ID_S.nextval,
    c2.action_id,
    c2.appr_hierarchy_id,
    c2.appr_category_id,
    c2.appr_type_id,
    c2.appr_level,
    c2.action_sequence_num,
    l_from_person_id,
    l_from_person_id,
    lo_moreinfo_id,
    SYSTIMESTAMP,
    l_from_person_id,
    SYSTIMESTAMP,
    l_from_person_id,
    SYSTIMESTAMP,
    l_from_person_id,
    c2.appr_role_id,
    lo_moreinfo_name,
    SYSTIMESTAMP,
    p_login_user,
    ll_moreinfo_type,
    lo_moreinfo_id,
    lo_moreinfo_name
);
commit;
--DBMS_OUTPUT.PUT_LINE('Loop check'||sqlerrm);
l_action_history_id:=c2.ACTION_HISTORY_ID;
l_action_id:=c2.ACTION_ID;
end loop;
-----------------------------------------------
--DBMS_OUTPUT.PUT_LINE('==>'||l_action_history_id);
                --Update history table action date null update
                update fs_approval_action_history_t
                set
                ACTION_DATE=SYSTIMESTAMP,
                LAST_UPDATE_DATE=SYSTIMESTAMP
                where 
                1=1
                and ACTION_HISTORY_ID=l_action_history_id
                and ACTION_ID=l_action_id
                and ACTION_DATE is null
                and RESPONSE_USER_ID=l_from_person_id;
                commit;
                sys.dbms_session.sleep(5);
-----------------------------------------------
---group approval                
IF(upper(p_moreinfo_type)=upper('APPROVER_MORE_INFO')) then 
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
					and faah.TRANSACTION_ID=p_transaction_id
					and faah.APPR_LEVEL=l_appr_level
                    and faah.ACTION_TYPE_CODE='PENDING'
					and faah.ACTION_DATE is null
					group by faah.appr_level, faah.appr_category_code, faah.APPR_REQUEST_CODE,faah.APPR_REQUEST_CODE,faah.MODULE_NAME;
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
            ,status_code  = 'O'
            WHERE action_id = l_action_id;
            commit;
END IF;
--Transaction table status update
if(upper(p_module_name))=upper('TRAVEL_REQUEST')then 
                sys.dbms_session.sleep(5);
                update fs_travel_header_t
                set TRAVEL_STATUS_ID=FS_VALIDATION_UTILS.get_lookup_value_id('APPROVAL_ACTION','PENDING'),
                STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION',p_moreinfo_type),
                LAST_UPDATE_DATE=systimestamp,
                LAST_UPDATE_LOGIN=p_login_user
                where
                TRAVEL_HEADER_ID=p_transaction_id;
                COMMIT;
                ---overtime	
elsif(upper(p_module_name))=upper('OVER_TIME_REQUEST')then 
                update fs_over_time_hdr_t
                set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION','PENDING'),
                LAST_UPDATE_DATE=systimestamp,
                LAST_UPDATE_LOGIN=p_login_user
                where
                OVER_TIME_HDR_ID=p_transaction_id;
                COMMIT;
elsif(upper(p_module_name))=upper('SITE_OVERTIME_REQUEST')then 
                update fs_over_time_hdr_t
                set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION','PENDING'),
                LAST_UPDATE_DATE=systimestamp,
                LAST_UPDATE_LOGIN=p_login_user
                where
                OVER_TIME_HDR_ID=p_transaction_id;
                COMMIT;
elsif(upper(p_module_name))=upper('SELF_SERVICE') then 
                    update fs_request_details
                    set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION','PENDING'),
                    LAST_UPDATE_DATE=systimestamp,
                    LAST_UPDATE_LOGIN=p_login_user
                    where REQUEST_ID=p_transaction_id;
                    commit;
                       --voluntary exit
                    
                   elsif(upper(p_module_name))=upper('VOLUNTARY_EXIT') then 
                    update fs_request_details
                    set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION','PENDING'),
                    LAST_UPDATE_DATE=systimestamp,
                    LAST_UPDATE_LOGIN=p_login_user
                    where REQUEST_ID=p_transaction_id;
                    commit; 
                    
                    
                    --food request
                    
                    elsif(upper(p_module_name))=upper('FOOD_REQUEST') then 
                    update fs_request_details
                    set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION','PENDING'),
                    LAST_UPDATE_DATE=systimestamp,
                    LAST_UPDATE_LOGIN=p_login_user
                    where REQUEST_ID=p_transaction_id;
                    commit; 
                    
                    
                    --shutdown and emergency
                    
                    elsif(upper(p_module_name))=upper('SHUTDOWN_AND_EMERGENCY') then 
                    update fs_request_details
                    set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION','PENDING'),
                    LAST_UPDATE_DATE=systimestamp,
                    LAST_UPDATE_LOGIN=p_login_user
                    where REQUEST_ID=p_transaction_id;
                    commit;
                    
                    
                     elsif(upper(p_module_name))=upper('MOVEMENT_FORM') then 
    update fs_request_details
                    set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION','PENDING'),
                    LAST_UPDATE_DATE=systimestamp,
                    LAST_UPDATE_LOGIN=p_login_user
                    where REQUEST_ID=p_transaction_id;
                    commit;
       elsif(upper(p_module_name))=upper('JOB_ROTATION') then 
     update fs_request_details
                    set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION','PENDING'),
                    LAST_UPDATE_DATE=systimestamp,
                    LAST_UPDATE_LOGIN=p_login_user
                    where REQUEST_ID=p_transaction_id;
                    commit;
elsif(upper(p_module_name))=upper('LEARNING_REQUEST') then 
                        update fs_Learning_module_hdr_t
                        set REQUEST_STATUS=FS_VALIDATION_UTILS.get_lookup_value_name('APPROVAL_ACTION','PENDING'),
                        LAST_UPDATE_DATE=systimestamp,
                        LAST_UPDATE_LOGIN=p_login_user
                        where LEARNING_MODULE_HDR_ID=p_transaction_id;
                        commit;
end if;   
----Mail
if(upper(p_moreinfo_type)=upper('APPROVER_MORE_INFO')) then 
    begin 
        FS_MAIL_NOTIFICATION_PKG.REQUEST_DETAIL_MAIL(l_appr_request_code,p_transaction_id,'MORE_INFO',lSTATUS);
    end; 
elsif(upper(p_moreinfo_type)=upper('EMP_MORE_INFO'))then 
----Mail
begin 
FS_MAIL_NOTIFICATION_PKG.REQUEST_DETAIL_MAIL(l_appr_request_code,p_transaction_id,'MORE_INFO',lSTATUS);
end;         
end if;


----------------------------
end if;
    p_action_id:=l_action_id;
    p_callsubmitpackage:='NO';
    p_appr_process:=l_appr_request_code;
    p_user_id:=l_requester_user_id;
    p_error_code:='S';
    p_error_msg:='Success';
else
    p_action_id:=null;
    p_callsubmitpackage:=null;
    p_appr_process:=null;
    p_user_id:=null;
    p_error_code:='E';
    p_error_msg:='No Data Found';
end if;




END more_info_process;

END FS_APPROVAL_MORE_INFO_PKG;
/
