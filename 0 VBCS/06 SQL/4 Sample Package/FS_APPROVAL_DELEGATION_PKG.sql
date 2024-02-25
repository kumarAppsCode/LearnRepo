CREATE OR REPLACE PACKAGE "FS_APPROVAL_DELEGATION_PKG" 
IS

   PROCEDURE delegation_process(
                    p_action_id             in       number
                   ,p_tx_id                 in      varchar2                   
                   ,p_error_code            out     varchar2
                   ,p_error_msg             out     varchar2
                   );

END FS_APPROVAL_DELEGATION_PKG;
/


CREATE OR REPLACE PACKAGE BODY "FS_APPROVAL_DELEGATION_PKG" 
IS
   l_error_code   VARCHAR2(1) := 'S';
   l_error_msg    VARCHAR2(2000);


   PROCEDURE delegation_process(
                    p_action_id             in      number
                   ,p_tx_id             in      varchar2                   
                   ,p_error_code            out     varchar2
                   ,p_error_msg             out     varchar2
                   )
is

--l_action_id             fs_approval_action_t.ACTION_ID%TYPE;
--l_transaction_id        fs_approval_action_t.TRANSACTION_ID%TYPE;
--l_requester_user_id     fs_approval_action_t.REQUESTER_USER_ID%TYPE;
--l_requester_email_id    fs_approval_action_t.REQUESTER_EMAIL_ID%TYPE;
--l_action_history_id     fs_approval_action_history_t.ACTION_HISTORY_ID%TYPE;
--l_response_email_address   varchar2(2000); 

l_approver_level           NUMBER;
l_approver_category_code    VARCHAR2(30);
l_approver_user_id         VARCHAR2(2000);
l_approver_email_address   VARCHAR2(2000);
l_final_approver         VARCHAR2(240);


--
--l_new_approver_level           NUMBER;
--l_new_approver_category_code    VARCHAR2(30);
--l_new_approver_user_id         VARCHAR2(2000);
--l_new_approver_email_address   VARCHAR2(2000);
--l_new_appr_request_code         VARCHAR2(240);
--l_module_name                   VARCHAR2(240);

----------------
l_fyi_action_type_id NUMBER:= fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','NTY');
l_person_number varchar2(120);
l_vaction_count number;
l_to_person_number      XXNWS_VACATION_RULES_B.TO_PERSON_NUMBER%TYPE;
l_to_person_emailid     XXNWS_VACATION_RULES_B.TO_MAIL_ID%TYPE;
l_person_id             fs_person_stg_t.person_id%TYPE;
l_from_person_emailid   XXNWS_VACATION_RULES_B.FROM_MAIL_ID%TYPE;



--get current pending list
cursor approval_history(llevel number)
is
SELECT * 
FROM fs_approval_action_history_t
where 
1=1
and ACTION_ID=p_action_id
and APPR_LEVEL=llevel
and ACTION_DATE is null
and ACTION_TYPE_ID not in (l_fyi_action_type_id);

      CURSOR cur_action
      IS
         SELECT action_id
               ,appr_request_id
               ,transaction_id
               ,transaction_num
               ,requester_user_id
               ,requester_email_id
               ,approver_user_id
               ,approver_email_id
               ,approver_level
               ,approval_category_code
               ,status_code
            FROM fs_approval_action_t
          WHERE action_id = p_action_id;

rec_action   cur_action%ROWTYPE;
----------------

BEGIN

      l_error_code := 'S';
      l_error_msg := 'Successfully Updated';

      OPEN cur_action;
      FETCH cur_action INTO rec_action;
      CLOSE cur_action;

--DBMS_OUTPUT.PUT_LINE('l_level==>'||rec_action.action_id);
--DBMS_OUTPUT.PUT_LINE('l_level==>'||rec_action.transaction_id);
--DBMS_OUTPUT.PUT_LINE('l_level==>'||rec_action.approver_level);

--loop approval history table [only pending]
for c1 in approval_history(rec_action.approver_level)
loop
l_person_number:=null;
--get person number
begin
        SELECT 
        PERSON_NUMBER
        into
        l_person_number
        FROM fs_person_stg_t
        where 
        rownum=1
        and PERSON_ID=c1.RESPONSE_USER_ID;
    EXCEPTION
      WHEN OTHERS THEN
    l_person_number:=null;
end;

--DBMS_OUTPUT.PUT_LINE('l_person_number==>'||l_person_number);


--check vacation table count
begin 
    SELECT 
    count(*) as lcount,
    TO_PERSON_NUMBER, 
    TO_MAIL_ID,
    FROM_MAIL_ID
    into
    l_vaction_count,
    l_to_person_number,
    l_to_person_emailid,
    l_from_person_emailid    
    FROM XXNWS_VACATION_RULES_B
    where 
    1=1
    and rownum=1
    and upper(FROM_PERSON_NUMBER)=upper(l_person_number)
    and sysdate between to_date(START_DATE, 'DD-MON-YYYY') and to_date(END_DATE, 'DD-MON-YYYY')
    group by TO_PERSON_NUMBER, TO_MAIL_ID,FROM_MAIL_ID;
exception when others then
--check vacation table count
l_vaction_count:=null;
l_to_person_number:=null;
end;

--DBMS_OUTPUT.PUT_LINE('l_vaction_count==>'||l_vaction_count);
--DBMS_OUTPUT.PUT_LINE('l_to_person_number==>'||l_to_person_number);
--DBMS_OUTPUT.PUT_LINE('l_to_person_emailid==>'||l_to_person_emailid);
--DBMS_OUTPUT.PUT_LINE('l_from_person_emailid==>'||l_from_person_emailid);

--get person id
begin
SELECT 
    PERSON_ID
        into
        l_person_id
        FROM fs_person_stg_t
        where 
        rownum=1
        and person_number=l_to_person_number;
EXCEPTION
      WHEN OTHERS THEN
    l_person_id:=null;
end;

--DBMS_OUTPUT.PUT_LINE('l_person_id==>'||l_person_id);
--insert into history table 
if(l_person_id is not null and l_vaction_count is not null) then 
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
        fs_approval_action_history_id_s.NEXTVAL,
        c1.action_id,
        c1.appr_hierarchy_id,
        c1.appr_category_id,
        c1.appr_type_id,
        c1.appr_level,
        c1.action_sequence_num,
        c1.response_user_id,
        l_person_id, 
        c1.action_type_id,
        c1.response_user_id,
        SYSTIMESTAMP,
        c1.response_user_id,
        SYSTIMESTAMP,
        c1.response_user_id,
        c1.appr_role_id
    );
commit;
--update history table delegation
update fs_approval_action_history_t
set
ACTION_DATE=SYSTIMESTAMP,
ACTION_COMMENTS='Delegation',
APPROVER_ACTION_DATE=SYSTIMESTAMP,
LAST_UPDATE_DATE=SYSTIMESTAMP,
APPROVER_ACTION_COMMENTS='Delegation',
APPROVER_EMAIL_ID=l_from_person_emailid,
APPROVER_USER_ID=null,
APPROVER_ACTION_CODE='DELEGATION',
APPROVER_ACTION_TYPE_ID=(SELECT LOOKUP_VALUE_ID FROM fs_lookup_values_v where 
                                    rownum=1
                                    and LOOKUP_TYPE_NAME='APPROVAL_ACTION'
                                    and LOOKUP_VALUE_NAME='DELEGATION'),
ACTION_TYPE_ID=(SELECT LOOKUP_VALUE_ID FROM fs_lookup_values_v where 
                                    rownum=1
                                    and LOOKUP_TYPE_NAME='APPROVAL_ACTION'
                                    and LOOKUP_VALUE_NAME='DELEGATION')
where 
1=1
and ACTION_HISTORY_ID=c1.action_history_id;

commit;


end if;
end loop;
--
--To find out next approver         
         BEGIN
              SELECT faah.appr_level 
              ,faah.appr_category_code
              ,LISTAGG(faah.response_user_id
                            ,',')
                        approver_user_id
                    ,LISTAGG(faah.response_email_address
                            ,',')
                        approver_email_address
                INTO l_approver_level
                    ,l_approver_category_code
                    ,l_approver_user_id
                    ,l_approver_email_address
                FROM fs_approval_action_history_v faah 
               WHERE faah.action_id = rec_action.action_id
                 and faah.ACTION_DATE is null
                 AND faah.appr_level = rec_action.approver_level
                -- AND ACTION_TYPE_ID=fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','NTY')
             group by faah.appr_level, faah.appr_category_code;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_approver_level := NULL;
               l_approver_category_code := NULL;
               l_approver_user_id := NULL;
               l_approver_email_address := NULL;
               l_final_approver := 'Y';
            WHEN OTHERS THEN
               l_error_code := 'E';
               l_error_msg := 'API Error';
         END;
        -- udpate in approval_action table new approval
         if(l_approver_email_address is not null) then 
             UPDATE fs_approval_action_t
                SET approver_user_id = l_approver_user_id
                   ,approver_email_id = l_approver_email_address
                   ,approver_level = l_approver_level
                   ,approval_category_code = l_approver_category_code
              WHERE action_id = rec_action.action_id;
              commit;         
         end if;
p_error_code:='S';
p_error_msg:='Success';

END delegation_process;

END FS_APPROVAL_DELEGATION_PKG;
/
