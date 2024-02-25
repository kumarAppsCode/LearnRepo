CREATE OR REPLACE PACKAGE fs_approval_process_pkg
IS

   FUNCTION get_email_address(p_user_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_user_id(p_user_name IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE update_pcs_instance_num (
        p_trx_id          in varchar2
      , p_instance_num    in varchar2
      , p_error_code      out varchar2
      , p_error_msg       out varchar2
    );


   PROCEDURE submit(p_appr_process IN     VARCHAR2
                   ,p_trx_id       IN     NUMBER
                   ,p_user_id      IN     NUMBER
                   ,p_action_id       OUT NUMBER
                   ,p_error_code      OUT VARCHAR2
                   ,p_error_msg       OUT VARCHAR2);



   PROCEDURE update_action(p_action_id    IN     NUMBER
                          ,p_trx_id       IN     NUMBER
                          ,p_action_user  IN     VARCHAR2
                          ,p_action_code  IN     VARCHAR2
                          ,p_comments     IN     VARCHAR2
                          ,p_error_code      OUT VARCHAR2
                          ,p_error_msg       OUT VARCHAR2);


--   PROCEDURE get_approval_detail(
--        p_appr_process    IN VARCHAR2
--      , p_trx_id          IN VARCHAR2
--      , p_result         OUT SYS_REFCURSOR
--    );


END fs_approval_process_pkg;
/


CREATE OR REPLACE PACKAGE BODY fs_approval_process_pkg
IS
   l_error_code   VARCHAR2(1) := 'S';
   l_error_msg    VARCHAR2(2000);

   FUNCTION get_email_address(p_user_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_email_address VARCHAR2(240);
   BEGIN

    SELECT EMAIL_ADDRESS 
    INTO l_email_address
    FROM fs_person_stg_v 
    where 
    rownum=1
    and PERSON_ID=p_user_id;

--      SELECT email_address
--        INTO l_email_address
--        FROM fs_users_v
--       WHERE user_id = p_user_id;
--       WHERE person_id = p_user_id;

      RETURN (l_email_address);
   EXCEPTION
      WHEN OTHERS THEN
--         RETURN (NULL);

      SELECT email_address
        INTO l_email_address
        FROM fs_users_v
       WHERE user_id = p_user_id;
--    WHERE person_id = p_user_id;    


        RETURN l_email_address;
   END get_email_address;




   FUNCTION get_user_id(p_user_name IN VARCHAR2)
      RETURN NUMBER
   IS
      l_user_id      NUMBER:=300000005498917;
   BEGIN
      SELECT 
      PERSON_ID
--    user_id
        INTO l_user_id
        FROM fs_users_v
        WHERE 
        rownum=1
        and UPPER(EMAIL_ADDRESS) = UPPER(p_user_name);
--       WHERE UPPER(user_name) = UPPER(p_user_name);

      RETURN (l_user_id);
   EXCEPTION
      WHEN OTHERS THEN
--         RETURN (NULL);
         RETURN (l_user_id);
   END get_user_id;


    PROCEDURE update_pcs_instance_num (
        p_trx_id          in varchar2
      , p_instance_num    in varchar2
      , p_error_code      out varchar2
      , p_error_msg       out varchar2
    )
    is
--    l_error_code VARCHAR2(1) := 'S';
--    l_error_msg  VARCHAR2(2000);
    BEGIN
    --    SUBSTR(p_trn_num,6)
        UPDATE FS_APPROVAL_ACTION_T
        SET APPROVAL_PCS_INSTANCE_NUM=P_INSTANCE_NUM
        WHERE 
        ROWNUM=1 
        and STATUS_CODE in ('O')
        and APPROVER_EMAIL_ID is not null
        AND TRANSACTION_ID=p_trx_id;

        l_error_code := 'S';
        l_error_msg := 'Updated Successfully';
        COMMIT;

        p_error_code := l_error_code;
        p_error_msg := l_error_msg;
    EXCEPTION WHEN OTHERS THEN 
        l_error_code := 'E';
        l_error_msg := SQLERRM;

        p_error_code := l_error_code;
        p_error_msg := l_error_msg;    

    END update_pcs_instance_num;



   PROCEDURE submit(p_appr_process IN     VARCHAR2
                   ,p_trx_id       IN     NUMBER
                   ,p_user_id      IN     NUMBER
                   ,p_action_id       OUT NUMBER
                   ,p_error_code      OUT VARCHAR2
                   ,p_error_msg       OUT VARCHAR2)
   IS
      CURSOR cur_appr(p_appr_level NUMBER, p_person_id NUMBER)
      IS
--           SELECT fah.appr_hierarchy_id
--                 ,fah.appr_request_id
--                 ,fah.appr_request_code
--                 ,fah.appr_request_name
--                 ,fah.appr_category_id
--                 ,fah.appr_category_code
--                 ,fah.appr_category_name
--                 ,fah.appr_type_id
--                 ,fah.appr_type_code
--                 ,fah.appr_type_name
--                 ,fah.appr_level
--                 ,fah.appr_role_id
--                 ,fah.appr_role_code appr_role_code
--                 ,fah.appr_role_name appr_role_name
--                 ,fah.appr_user_id
--             FROM FS_APPROVAL_HIERARCHY_DTL_V fah
----             fs_approval_hierarchy_v fah
--            WHERE fah.appr_request_code = p_appr_process
--              AND fah.appr_level > p_appr_level
--              and fah.appr_user_id is not null
--         ORDER BY fah.appr_level
--                 ,fah.appr_user_id;

          select * from 
          ( 
            SELECT            
                  fah.appr_hierarchy_id
                 ,fah.appr_request_id
                 ,fah.appr_request_code
                 ,fah.appr_request_name
                 ,fah.appr_category_id
                 ,fah.appr_category_code
                 ,fah.appr_category_name
                 ,fah.appr_type_id
                 ,fah.appr_type_code
                 ,fah.appr_type_name
                 ,fah.appr_level
                 ,fah.appr_role_id
                 ,fah.appr_role_code appr_role_code
                 ,fah.appr_role_name appr_role_name
                 ,(
                 case 
                 when fah.appr_role_code in ('LINE_MANAGER_BASE',
                 'VEC_FIRST_SUPERIOR',
                 'VEC_FIRST_LEVEL_SUPERVISOR',
                 'VEC_REPORTING_SUPERVISOR') then 
                 (
                     SELECT
                     NVL(MAX(ass.SUPERVISOR_ID),100000003250056)
                     FROM
                     fs_assignment_stg_t ass
                     WHERE
                            ass.person_id = p_person_id
                        and ass.LAST_UPDATE_DATE =
                        (SELECT MAX(asst.LAST_UPDATE_DATE) 
                        FROM fs_assignment_stg_t asst 
                        where asst.PERSON_ID=p_person_id)
                        AND ROWNUM = 1
                 )
                 when fah.appr_role_code='LINE_MANAGER_2' then 
                 (
                     SELECT
                     NVL(MAX(ass.SUPERVISOR_ID),100000003250056)
                     FROM
                     fs_assignment_stg_t ass
                     WHERE
                            ass.person_id = p_person_id
                        and ass.LAST_UPDATE_DATE =
                        (SELECT MAX(asst.LAST_UPDATE_DATE) 
                        FROM fs_assignment_stg_t asst 
                        where asst.PERSON_ID=p_person_id)
                        AND ROWNUM = 1
                 )
                 when fah.appr_role_code='MOVEMENT_NEW_LINE_MANAGER' then 
                 (
                    SELECT 
                    to_number(rd.REQUEST_DATA.sm_line_manager_id) as new_line_manger 
                    FROM fs_request_details rd 
                    where rownum=1 and rd.REQUEST_ID=p_trx_id
                 )
                when fah.appr_role_code='JOB_ROTATION_NEW_LINE_MANGER' then 
                 (
                    SELECT 
                    to_number(rd.REQUEST_DATA.jr_linemanager_id) as new_line_manger 
                    FROM fs_request_details rd 
                    where rownum=1 and rd.REQUEST_ID=p_trx_id
                 )
                 when fah.appr_role_code='PROPOSED_DEPARTMENT_MANAGER' then 
                 (
                    select 
                        NVL(PERSON_ID,100000003250056)
                    from 
                        fs_per_asg_responsibilities_t
                        where 1=1
                        and rownum=1
                        AND (RESPONSIBILITY_TYPE LIKE '%Manager' or RESPONSIBILITY_TYPE LIKE '%Head')
                        AND TRUNC(sysdate) between TRUNC(from_date) and nvl(TRUNC(to_date),sysdate+1)
                        and TOP_ORGANIZATION_ID
                        in (SELECT 
                        rd.REQUEST_DATA.sm_proposed_department
                        FROM fs_request_details rd 
                        where 
                        1=1
                        and rownum=1
                        and REQUEST_TYPE like 'MOVEMENT_FORM'
                        and REQUEST_ID=p_trx_id
                        )
                 )
                  when fah.appr_role_code='PROPOSED_DEPARTMENT_MANAGER_JOB' then 
                 (
                    SELECT DISTINCT
                    NVL(q1.person_id,100000003250056)
                    --    ,q1.person_number
                    --    ,q1.full_name person_name
                    --    ,q1.email_address
                    FROM
                        fs_employee_detail_v             q1,
                        fs_organization_hierarchy_detail q2
                    WHERE
                            1 = 1
                        AND EXISTS (
                            SELECT
                                1
                            FROM
                                fs_employee_supervisor q3
                            WHERE
                                q3.supervisor_id = q1.person_id
                        )
                        AND q1.department_id = q2.organization_id
                        AND upper(q2.department_id) IN (SELECT 
                                            rd.REQUEST_DATA.jr_proposed_department
                                            FROM fs_request_details rd 
                                            where 
                                            1=1
                                            and rownum=1
                                            and REQUEST_TYPE like 'JOB_ROTATION'
                                            and REQUEST_ID=p_trx_id)
                 )
                 when fah.appr_role_code='VEC_FLEET_COORDINATOR_RG' then 
                 (
                    SELECT
                    to_number(XXNWS_GET_VEHICLE_RG_APPR(p_trx_id))
                    FROM DUAL
                 )
               --  when fah.appr_role_code='DEPARTMENT_BASE' then 
                   when fah.appr_role_code in('DEPARTMENT_BASE','CURRENT_DEPARTMENT_BASE') then 
                 (
--                    SELECT
--                     NVL(MAX(ass.SUPERVISOR_ID),100000003250056)
--                     FROM
--                     fs_assignment_stg_t ass
--                     WHERE
--                            ass.person_id = p_person_id
--                        and ass.LAST_UPDATE_DATE =
--                        (SELECT MAX(asst.LAST_UPDATE_DATE) 
--                        FROM fs_assignment_stg_t asst 
--                        where asst.PERSON_ID=p_person_id)
--                        AND ROWNUM = 1
SELECT
to_number(xxnws_get_org_manager(p_person_id,'DEPT','PERSON_ID',sysdate))
FROM DUAL
                 )
                 when fah.appr_role_code in('GM_EMPLOYEE_DIVISION','DEPARTMENT_GM','TNI_DIV_GM','VEC_GM_DIV_APPROVAL_GROUP','GM_SR_MANAGER_DIV_DIR','DIVISION_MANAGER','EMPLOYEE_GM','DIVISION_GM','PROPOSED_DIVISION_GM') then 
                 (
                  SELECT
                     to_number(NVL(NVL(xxnws_get_org_manager(p_person_id,'DIV','PERSON_ID',sysdate),xxnws_get_org_manager(p_person_id,'DIR','PERSON_ID',sysdate)),
                     xxnws_get_org_manager(p_person_id,'SD_DIR','PERSON_ID',sysdate)))
                   FROM DUAL
                   /*
                     SELECT
                     NVL(MAX(ass.SUPERVISOR_ID),100000003250056)
                     FROM
                     fs_assignment_stg_t ass
                     WHERE
                     ass.person_id = p_person_id
                     and ass.LAST_UPDATE_DATE =
                     (SELECT MAX(asst.LAST_UPDATE_DATE) 
                     FROM fs_assignment_stg_t asst 
                     where asst.PERSON_ID=p_person_id)
                     AND ROWNUM = 1
                     */
                 )
                 when fah.appr_role_code in('CHIEF_SR_DIR') 
                 then(
                    SELECT
                    to_number(xxnws_get_org_manager(p_person_id,'SR_DIR','PERSON_ID',sysdate))
                    FROM DUAL)
                 when fah.appr_role_code in('OPERATIONAL_FOCAL_POINT') 
                 then(
                    SELECT
                    to_number(xxnws_get_oper_focal_point(p_person_id))
                    FROM DUAL)   
                 else
                    fah.appr_user_id
                 end 
                 ) as appr_user_id

             FROM FS_APPROVAL_HIERARCHY_DTL_V fah
--             fs_approval_hierarchy_v fah
            WHERE 
              fah.appr_request_code = p_appr_process
              AND fah.appr_level > p_appr_level
--            and fah.appr_user_id is not null
--            and fah.appr_user_id is not null
          )
         where appr_user_id is not null  
         ORDER BY appr_level,appr_user_id;


      l_appr_level   NUMBER;
      l_appr_level_f NUMBER;
      l_approver_level NUMBER;
      l_requester_user_id NUMBER;
      l_action_sequence_num NUMBER;
      l_approver_category_code VARCHAR2(30);
      l_approver_user_id VARCHAR2(2000);
      l_approver_email_address VARCHAR2(2000);
--      l_action_id    NUMBER := fs_approval_action_history_id_s.NEXTVAL;
      l_action_id    NUMBER := ACTION_ID_S.NEXTVAL;
      l_action_type_id NUMBER:= fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','PENDING');
      l_close_action_type_id NUMBER:= fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','CLOSED');
      lperson_id NUMBER;  
      l_appr_process varchar2(540);
      lappr_category_id   number:= fs_utility_pkg.get_lookup_value_id('APPROVAL_CATEGORY','EMPLOYEE');
      lduplicate_count number:=0;
      lv_new_action_type_id number:= fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','PENDING');
      l_new_APPROVER_ACTION_COMMENTS varchar2(240):=null;
      l_new_APPROVER_ACTION_CODE varchar2(240):=null;
      l_new_APPROVER_ACTION_TYPE_ID number:=null;
    l_role_id number;  
    l_version number:=0;
    l_open_tx_count number:=0;
--- --17-Jan-2024==>login user and approver same - approval skipe   
 lv_ACTION_TYPE_ID			fs_approval_action_history_t.ACTION_TYPE_ID%type;
    lv_ACTION_DATE				fs_approval_action_history_t.ACTION_DATE%type;
    lv_ACTION_COMMENTS			fs_approval_action_history_t.ACTION_COMMENTS%type;
    lv_APPROVER_ACTION_DATE		fs_approval_action_history_t.APPROVER_ACTION_DATE%type;
    lv_APPROVER_ACTION_CODE		fs_approval_action_history_t.APPROVER_ACTION_CODE%type;
    lv_APPROVER_ACTION_TYPE_ID	fs_approval_action_history_t.APPROVER_ACTION_TYPE_ID%type;
    lv_LAST_UPDATE_LOGIN		fs_approval_action_history_t.LAST_UPDATE_LOGIN%type;
   BEGIN
      l_error_code := 'S';

      --To get the Approval Level for requested user
      BEGIN
         SELECT fah.appr_level
           INTO l_appr_level
           FROM fs_approval_hierarchy_v fah
          WHERE fah.appr_request_code = p_appr_process
            AND fah.appr_user_id = p_user_id;
        DBMS_OUTPUT.put_line ('l_appr_level >> ' || l_appr_level);    
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_appr_level := 0;
         WHEN OTHERS THEN
            l_error_code := 'E';
            l_error_msg := 'API Error';
      END;

begin
    select 
    count(*) 
    into l_open_tx_count
    FROM fs_approval_action_t
    where TRANSACTION_ID=p_trx_id
    and STATUS_CODE='O';
exception when others then 
    l_open_tx_count:=1;
end;


      IF (l_error_code = 'S' and l_open_tx_count=0) THEN
         l_requester_user_id := p_user_id;
         l_action_sequence_num := 10;

        -- Person Id
--        begin
--            SELECT 
--            distinct PERSON_ID 
--            into lperson_id
--            FROM fs_users_stg_v 
--            where 
--            rownum=1
--            and USER_ID=p_user_id;
--        exception when others then 
--        lperson_id:=0;
--        end;
--       lperson_id

         FOR rec_appr IN cur_appr(l_appr_level, p_user_id) 
         LOOP
           --17-Jan-2024==>login user and approver same - approval skipe            
            lv_ACTION_TYPE_ID			:=l_action_type_id;
            lv_ACTION_DATE				:=null;
            lv_ACTION_COMMENTS			:=null;
            lv_APPROVER_ACTION_DATE		:=null;
            lv_APPROVER_ACTION_CODE		:=null;
            lv_APPROVER_ACTION_TYPE_ID	:=l_action_type_id;
            lv_LAST_UPDATE_LOGIN		:=null;
            ------            
           if(p_user_id=rec_appr.appr_user_id) then 
            lv_ACTION_TYPE_ID			:=l_close_action_type_id;
            lv_ACTION_DATE				:=systimestamp;
            lv_ACTION_COMMENTS			:='Approval Skipped';
            lv_APPROVER_ACTION_DATE		:=systimestamp;
            lv_APPROVER_ACTION_CODE		:='CLOSED';
            lv_APPROVER_ACTION_TYPE_ID	:=l_close_action_type_id;
            lv_LAST_UPDATE_LOGIN		:=rec_appr.appr_user_id;
           else
            lv_ACTION_TYPE_ID			:=l_action_type_id;
            lv_ACTION_DATE				:=null;
            lv_ACTION_COMMENTS			:=null;
            lv_APPROVER_ACTION_DATE		:=null;
            lv_APPROVER_ACTION_CODE		:=null;
            lv_APPROVER_ACTION_TYPE_ID	:=l_action_type_id;
            lv_LAST_UPDATE_LOGIN		:=null;
           end if;
         
--duplicate change
--          if(lappr_category_id=rec_appr.appr_category_id) then 
--            SELECT COUNT('X')
--            INTO lduplicate_count
--            FROM
--            fs_approval_action_history_t
--            WHERE
--            action_id = l_action_id
--            and RESPONSE_USER_ID=rec_appr.appr_user_id
--            and APPR_LEVEL=rec_appr.appr_level-1
--            and appr_role_id not in (SELECT ROLE_ID FROM fs_approval_role_t
--                                     where 
--                                     ROLE_CODE IN ('TRAVEL_SECTION', 'TRAVEL_SECTION2', 'TRAVEL_SUPERVISOR'));
--          end if;
--
--
--
--            IF lduplicate_count = 0 THEN
--               lv_new_action_type_id := l_action_type_id;
--                l_new_APPROVER_ACTION_COMMENTS:=null;
--                l_new_APPROVER_ACTION_CODE:=null;
--                l_new_APPROVER_ACTION_TYPE_ID:=null;
--            ELSE
--                lv_new_action_type_id := l_close_action_type_id;
--                l_new_APPROVER_ACTION_COMMENTS:='Approval Skipped [Previous Level Approval Process Completed]';
--                l_new_APPROVER_ACTION_CODE:='CLOSED';
--                l_new_APPROVER_ACTION_TYPE_ID:=l_close_action_type_id;
--
--            END IF;






            INSERT INTO fs_approval_action_history_t(action_history_id
                                                    ,action_id
                                                    ,appr_hierarchy_id
                                                    ,appr_category_id
                                                    ,appr_type_id
                                                    ,appr_level
                                                    ,action_sequence_num
                                                    ,requester_user_id
                                                    ,response_user_id
                                                    ,action_type_id
                                                    ,appr_role_id
                                                    ,action_date
                                                    ,action_comments
                                                    ,created_by
                                                    ,creation_date
                                                    ,last_updated_by
                                                    ,last_update_date
                                                    ,last_update_login
                                                    ,APPROVER_ACTION_COMMENTS
                                                    ,APPROVER_ACTION_CODE
                                                    ,APPROVER_ACTION_TYPE_ID

                                                    )
                 VALUES (fs_approval_action_history_id_s.NEXTVAL       --action_history_id
                        ,l_action_id                                   --action_id
                        ,rec_appr.appr_hierarchy_id                    --appr_hierarchy_id
                        ,rec_appr.appr_category_id                     --appr_category_id
                        ,rec_appr.appr_type_id                         --appr_type_id
                        ,rec_appr.appr_level                           --appr_level
                        ,l_action_sequence_num                         --action_sequence_num
                        ,l_requester_user_id                           --requester_user_id
                        ,rec_appr.appr_user_id                        --response_user_id
                        ,lv_ACTION_TYPE_ID                              --action_type_id
                       -- ,lv_new_action_type_id                           --action_type_id
                        ,rec_appr.appr_role_id
                        ,lv_ACTION_DATE                                         --action_date
                        ,lv_ACTION_COMMENTS                                         --action_comments
                        ,p_user_id                                    --created_by
                        ,SYSDATE                                      --creation_date
                        ,p_user_id                                    --last_updated_by
                        ,SYSDATE                                      --last_update_date
                        ,p_user_id                                    --last_update_login
                         ,lv_ACTION_COMMENTS
                        ,lv_APPROVER_ACTION_CODE
                        ,lv_APPROVER_ACTION_TYPE_ID
                         );

            --            DBMS_OUTPUT.put_line ('l_action_sequence_num >> ' || l_action_sequence_num);

            IF l_action_sequence_num = 10 THEN
               l_appr_level_f := rec_appr.appr_level;
               l_approver_category_code := rec_appr.appr_category_code;
            END IF;

            --            DBMS_OUTPUT.put_line ('l_appr_level_f >> ' || l_appr_level_f);

            IF rec_appr.appr_level = l_appr_level_f THEN
               IF l_approver_user_id IS NOT NULL THEN
                  l_approver_user_id := l_approver_user_id || ',' || rec_appr.appr_user_id;
               ELSE
                  l_approver_user_id := rec_appr.appr_user_id;
               END IF;

               IF l_approver_email_address IS NOT NULL THEN
                  l_approver_email_address := l_approver_email_address || ',' || get_email_address(rec_appr.appr_user_id);
               ELSE
                  l_approver_email_address := get_email_address(rec_appr.appr_user_id);
               END IF;
            END IF;


            /*IF l_approver_level <> rec_appr.appr_level THEN
               l_requester_user_id   := rec_appr.appr_user_id;
            END IF;*/
            l_requester_user_id := rec_appr.appr_user_id;
            DBMS_OUTPUT.put_line('l_approver_level >> ' || l_approver_level);
            DBMS_OUTPUT.put_line('rec_appr.appr_level >> ' || rec_appr.appr_level);
            DBMS_OUTPUT.put_line('l_requester_user_id >> ' || l_requester_user_id);
            DBMS_OUTPUT.put_line('rec_appr.appr_user_id >> ' || rec_appr.appr_user_id);
            l_action_sequence_num := l_action_sequence_num + 10;
            l_approver_level := rec_appr.appr_level;
         END LOOP;

   --S==>[25-oct-duplicate logic change]
         --approval Action adding version 
         begin
         SELECT 
            count(*) 
            into l_version
            FROM fs_approval_action_t
            where TRANSACTION_ID=p_trx_id;
         exception when others then 
            l_version:=0;
         end;
        --E==>[25-oct-duplicate logic change]      


         INSERT INTO fs_approval_action_t(action_id
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
                                         ,created_by
                                         ,creation_date
                                         ,last_updated_by
                                         ,last_update_date
                                         ,last_update_login)
              VALUES (l_action_id                                                                                                                                                                                                    --action_id
                     ,fs_utility_pkg.get_lookup_value_id('APPROVAL_SCREEN',p_appr_process)                                                                                                                                                       --appr_request_id
                     ,p_trx_id                                                                                                                                                                                                  --transaction_id
                     ,l_version                                                                                                                                                                                                     --transaction_num
                     ,p_user_id                                                                                                                                                                                              --requester_user_id
                     ,get_email_address(p_user_id)                                                                                                                                                                          --requester_email_id
                     ,l_approver_user_id                                                                                                                                                                                      --approver_user_id
                     ,l_approver_email_address                                                                                                                                                                               --approver_email_id
                     ,l_appr_level_f                                                                                                                                                                                            --approver_level
                     ,l_approver_category_code                                                                                                                                                                          --approval_category_code
                     ,'O'                                                                                                                                                                                                          --status_code
                     ,p_user_id                                                                                                                                                                                                     --created_by
                     ,SYSDATE                                                                                                                                                                                                    --creation_date
                     ,p_user_id                                                                                                                                                                                                --last_updated_by
                     ,SYSDATE                                                                                                                                                                                                 --last_update_date
                     ,p_user_id                                                                                                                                                                                              --last_update_login
                               );


            begin
            SELECT 
            DESCRIPTION 
            into 
            l_appr_process
            FROM fs_lookup_values_v 
            where 
            rownum=1
            and LOOKUP_TYPE_NAME='APPROVAL_SCREEN'
            and upper(LOOKUP_VALUE_NAME)=upper(p_appr_process);
            exception when others then
            l_appr_process:='-1';
            end;

            IF upper('SELF_SERVICE')= upper(l_appr_process)
            THEN
                UPDATE fs_request_details
                   SET 
                    LAST_UPDATE_DATE= SYSDATE,
                    REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','PENDING')
                 WHERE REQUEST_ID = p_trx_id;
                COMMIT ;
--       
elsif upper('VOLUNTARY_EXIT')= upper(l_appr_process)
            THEN
                UPDATE fs_request_details
                   SET 
                    LAST_UPDATE_DATE= SYSDATE,
                    REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','PENDING')
                 WHERE REQUEST_ID = p_trx_id;
                COMMIT ;
                
                
                  elsif upper('SHUTDOWN_AND_EMERGENCY')= upper(l_appr_process)
            THEN
                UPDATE fs_request_details
                   SET 
                    LAST_UPDATE_DATE= SYSDATE,
                    REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','PENDING')
                 WHERE REQUEST_ID = p_trx_id;
                COMMIT ;
                
                
                
                  elsif upper('FOOD_REQUEST')= upper(l_appr_process)
            THEN
                UPDATE fs_request_details
                   SET 
                    LAST_UPDATE_DATE= SYSDATE,
                    REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','PENDING')
                 WHERE REQUEST_ID = p_trx_id;
                COMMIT ;     
                
                
                elsif upper('MOVEMENT_FORM')= upper(l_appr_process) THEN
                UPDATE fs_request_details
                   SET 
                    LAST_UPDATE_DATE= SYSDATE,
                    REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','PENDING')
                 WHERE REQUEST_ID = p_trx_id;
                COMMIT ;
                 elsif upper('JOB_ROTATION')= upper(l_appr_process) THEN
                UPDATE fs_request_details
                   SET 
                    LAST_UPDATE_DATE= SYSDATE,
                    REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','PENDING')
                 WHERE REQUEST_ID = p_trx_id;
                COMMIT ;
            elsif upper('TRAVEL_REQUEST')= upper(l_appr_process) THEN
                UPDATE fs_travel_header_t
                   SET 
                    LAST_UPDATE_DATE= SYSDATE,
                    TRAVEL_STATUS_ID = FS_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','PENDING')
                 WHERE TRAVEL_HEADER_ID = p_trx_id;
                COMMIT ;
            elsif upper('LEARNING_REQUEST')= upper(l_appr_process) THEN
                UPDATE fs_learning_module_hdr_t
                   SET 
                    LAST_UPDATE_DATE= SYSDATE,
                    REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','PENDING')
                 WHERE LEARNING_MODULE_HDR_ID = p_trx_id;
                COMMIT ;
            elsif upper('OVER_TIME_REQUEST')= upper(l_appr_process) THEN
                update FS_OVER_TIME_HDR_T
                set 
                    LAST_UPDATE_DATE= SYSDATE,
                    REQUEST_STATUS=FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','PENDING')
                    where 
                    OVER_TIME_HDR_ID=p_trx_id;
                COMMIT ;
                    elsif upper('SITE_OVERTIME_REQUEST')= upper(l_appr_process) THEN
                update FS_OVER_TIME_HDR_T
                set 
                    LAST_UPDATE_DATE= SYSDATE,
                    REQUEST_STATUS=FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','PENDING')
                    where 
                    OVER_TIME_HDR_ID=p_trx_id;
                COMMIT ;
            elsif p_appr_process = 'CERTIFICATION' THEN
                UPDATE fs_request_details
                   SET 
                    LAST_UPDATE_DATE= SYSDATE,
                    REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','PENDING')
                 WHERE REQUEST_ID = p_trx_id;
                COMMIT ;
            END IF;
         l_error_msg := 'Successfully Submitted the Approval Process'||l_appr_process;
      else
          l_action_id:=0;
          p_error_code:='E';
          p_error_msg:='Previous Approval Open';
      END IF;

      p_action_id := l_action_id;
      p_error_code := l_error_code;
      p_error_msg := l_error_msg;
   END submit;

   PROCEDURE update_action(p_action_id    IN     NUMBER
                          ,p_trx_id       IN     NUMBER
                          ,p_action_user  IN     VARCHAR2
                          ,p_action_code  IN     VARCHAR2
                          ,p_comments     IN     VARCHAR2
                          ,p_error_code      OUT VARCHAR2
                          ,p_error_msg       OUT VARCHAR2)
   IS
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

      rec_action     cur_action%ROWTYPE;
      l_action_user_id NUMBER;
      l_approver_level NUMBER;
      l_approver_category_code VARCHAR2(30);
      l_approver_user_id VARCHAR2(2000);
      l_approver_email_address VARCHAR2(2000);
      l_final_approver VARCHAR2(1);
      l_appr_process VARCHAR2(240);
      l_err_code     VARCHAR2(1);
      l_err_msg      VARCHAR2(2000);
     -- l_current_approver_emailid    number;
       l_current_approver_emailid    VARCHAR2(2000);

      l_pending_action_id number:=fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION', 'PENDING');

      l_pending_action_name VARCHAR2(240):=fs_utility_pkg.get_lookup_value_name('APPROVAL_STATUS', 'PENDING');
       -- l_pending_action_name VARCHAR2(240):=fs_utility_pkg.get_lookup_value_name('APPROVAL_STATUS', 'DRAFT');
 l_close_action_id number:=fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','CLOSED'); 
     l_emp_category_id number:=fs_utility_pkg.get_lookup_value_id('APPROVAL_CATEGORY', 'EMPLOYEE');



       --E==>[25-oct-duplicate logic change]
      l_next_action_history_id number;
      l_next_action_count number;


      --S==>[25-oct-duplicate logic change]--
        cursor first_stge_approver(p_action_id number, ll_app_level number)
        is 
        SELECT 
        RESPONSE_USER_ID 
        FROM fs_approval_action_history_t where ACTION_ID=p_action_id
        and APPR_LEVEL=ll_app_level;

        cursor next_stage_approver(p_action_id number, ll_app_level number, p_response_user_id number)
        is 
        SELECT 
        * 
        FROM fs_approval_action_history_t 
        where ACTION_ID=p_action_id
        and APPR_LEVEL=ll_app_level+1
        and RESPONSE_USER_ID=p_response_user_id;
    --S==>[25-oct-duplicate logic change]--


   BEGIN
      l_error_code := 'S';
      l_error_msg := 'Successfully Updated';
      l_final_approver := 'N';
      l_action_user_id := get_user_id(p_action_user);

      OPEN cur_action;
      FETCH cur_action INTO rec_action;
      CLOSE cur_action;

      l_appr_process := fs_utility_pkg.get_lookup_value_code(rec_action.appr_request_id);


      if(p_action_user ='d0c322319888403191fc183903633c88') then 
      l_action_user_id:=100000003314280;
      end if;


        begin
            SELECT 
            DESCRIPTION 
            into 
            l_appr_process
            FROM fs_lookup_values_v 
            where 
            rownum=1
            and LOOKUP_TYPE_NAME='APPROVAL_SCREEN'
            and upper(LOOKUP_VALUE_NAME)=upper(l_appr_process);
            exception when others then
            l_appr_process:='-1';
        end;

        begin
        SELECT 
            APPROVER_EMAIL_ID 
            into 
            l_current_approver_emailid
            FROM fs_approval_action_history_t
            where 
            1=1
            and APPROVER_ACTION_DATE is not null
            AND APPROVER_EMAIL_ID IS NOT NULL
            and ACTION_ID=p_action_id
            and APPR_LEVEL= (SELECT 
            MAX(APPR_LEVEL) FROM fs_approval_action_history_t
            where 1=1
            AND APPROVER_EMAIL_ID IS NOT NULL
            and APPROVER_ACTION_DATE is not null
            and ACTION_ID=p_action_id);
--          and APPR_LEVEL=rec_action.approver_level;
        exception when others then 
            l_current_approver_emailid:='System Approver';
        end;


      IF p_action_code = 'APPROVE' THEN


    --S==>[25-oct-duplicate logic change]--         
        for c1 in first_stge_approver(p_action_id, rec_action.approver_level)
        loop
            for c2 in next_stage_approver(p_action_id,rec_action.approver_level, c1.RESPONSE_USER_ID)
            loop
            --
--                DBMS_OUTPUT.PUT_LINE('==>'||p_action_id);
--                DBMS_OUTPUT.PUT_LINE('==>'||rec_action.approver_level);
--                DBMS_OUTPUT.PUT_LINE('==>'||c1.RESPONSE_USER_ID);
--                DBMS_OUTPUT.PUT_LINE('l_pending_action_id==>'||l_pending_action_id);
--                DBMS_OUTPUT.PUT_LINE('ACTION_HISTORY_ID==>'||c2.ACTION_HISTORY_ID);
                update fs_approval_action_history_t
                set 
                ACTION_TYPE_ID=fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','CLOSED'), 
--    ACTION_TYPE_ID=l_close_action_id,
                ACTION_DATE=systimestamp, 
                ACTION_COMMENTS='Approval Skipped',
                APPROVER_ACTION_DATE=systimestamp, 
                APPROVER_ACTION_COMMENTS='Approval Skipped', 
                APPROVER_EMAIL_ID=null, 
                APPROVER_USER_ID=null, 
                APPROVER_ACTION_CODE='CLOSED', 
                APPROVER_ACTION_TYPE_ID=fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','CLOSED'),
--                 APPROVER_ACTION_TYPE_ID=l_close_action_id,
                LAST_UPDATE_DATE=systimestamp,
                LAST_UPDATE_LOGIN=c2.RESPONSE_USER_ID
                where 
                1=1
--                and ACTION_DATE is null
--                and APPR_CATEGORY_ID=l_emp_category_id
--                and RESPONSE_USER_ID=c1.RESPONSE_USER_ID
--                and NVL(APPROVER_ACTION_TYPE_ID,ACTION_TYPE_ID) =l_pending_action_id
                and ACTION_HISTORY_ID=c2.ACTION_HISTORY_ID;
                commit;
            end loop;
        end loop;
        --S==>[25-oct-duplicate logic change]--

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
               and faah.ACTION_DATE is null    ----S==>[25-oct-duplicate logic change]
                 AND faah.appr_level = (SELECT MIN(appr_level)
                                     FROM fs_approval_action_history_t
                                         WHERE action_id = rec_action.action_id
                                           AND ACTION_TYPE_ID=l_pending_action_id
                                           AND appr_level > rec_action.approver_level)
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

--DBMS_OUTPUT.PUT_LINE('==>'||l_action_user_id);
--DBMS_OUTPUT.PUT_LINE('l_final_approver==>'||l_final_approver);
--DBMS_OUTPUT.PUT_LINE('==>'||rec_action.action_id);
--DBMS_OUTPUT.PUT_LINE('==>'||rec_action.approver_level);


         UPDATE fs_approval_action_history_t
            SET action_type_id = CASE
                                    WHEN response_user_id = l_action_user_id THEN
                                       fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION'
                                                                         ,'APPROVE')
                                    ELSE
                                       fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION'
                                                                         ,'BEATEN')
                                 END
               ,action_date  = CASE WHEN response_user_id = l_action_user_id THEN SYSDATE ELSE NULL END -- beated user: null change to syddate [16april2023]
               ,action_comments = CASE WHEN response_user_id = l_action_user_id THEN p_comments ELSE NULL END  -- beated user: null change to comment [16april2023]
          WHERE action_id = rec_action.action_id
            AND appr_level = rec_action.approver_level;

         UPDATE fs_approval_action_t
            SET approver_user_id = l_approver_user_id
               ,approver_email_id = l_approver_email_address
               ,approver_level = l_approver_level
               ,approval_category_code = l_approver_category_code
               ,status_code  = CASE WHEN l_final_approver = 'Y' THEN 'A' ELSE 'O' END
          WHERE 
          status_code<>'C'
          and action_id = rec_action.action_id;

         IF l_final_approver = 'Y' THEN
            IF upper('SELF_SERVICE')= upper(l_appr_process) then
                UPDATE fs_request_details
                   SET 
                    LAST_UPDATED_BY=l_current_approver_emailid,
                    LAST_UPDATE_LOGIN=l_current_approver_emailid,
                    LAST_UPDATE_DATE= SYSDATE,
                     REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
--                   ,INTEGRATION_STATUS = 'S'
                 WHERE REQUEST_ID = rec_action.transaction_id;
                COMMIT ;
--                elsif upper('VOLUNTARY_EXIT')= upper(l_appr_process) then
--                UPDATE fs_request_details
--                   SET 
--                    LAST_UPDATED_BY=l_current_approver_emailid,
--                    LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                    LAST_UPDATE_DATE= SYSDATE,
--                     REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
----                      ,INTEGRATION_STATUS = 'S'
--                 WHERE REQUEST_ID = rec_action.transaction_id;
--                COMMIT ;
--                 elsif upper('FOOD_REQUEST')= upper(l_appr_process) then
--                UPDATE fs_request_details
--                   SET 
--                    LAST_UPDATED_BY=l_current_approver_emailid,
--                    LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                    LAST_UPDATE_DATE= SYSDATE,
--                     REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
----                      ,INTEGRATION_STATUS = 'S'
--                 WHERE REQUEST_ID = rec_action.transaction_id;
--                COMMIT ;
--                 elsif upper('SHUTDOWN_AND_EMERGENCY')= upper(l_appr_process) then
--                UPDATE fs_request_details
--                   SET 
--                    LAST_UPDATED_BY=l_current_approver_emailid,
--                    LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                    LAST_UPDATE_DATE= SYSDATE,
--                     REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
----                      ,INTEGRATION_STATUS = 'S'
--                 WHERE REQUEST_ID = rec_action.transaction_id;
--                COMMIT ;
--                  elsif upper('MOVEMENT_FORM')= upper(l_appr_process) THEN
--               UPDATE fs_request_details
--                   SET 
--                    LAST_UPDATED_BY=l_current_approver_emailid,
--                    LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                    LAST_UPDATE_DATE= SYSDATE,
--                     REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
----                   ,INTEGRATION_STATUS = 'S'
--                 WHERE REQUEST_ID = rec_action.transaction_id;
--                COMMIT ;
--                 elsif upper('JOB_ROTATION')= upper(l_appr_process) THEN
--                UPDATE fs_request_details
--                   SET 
--                    LAST_UPDATED_BY=l_current_approver_emailid,
--                    LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                    LAST_UPDATE_DATE= SYSDATE,
--                     REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
----                      ,INTEGRATION_STATUS = 'S'
--                 WHERE REQUEST_ID = rec_action.transaction_id;
--                COMMIT ;
                elsif upper('LEARNING_REQUEST')= upper(l_appr_process) THEN
                    UPDATE fs_learning_module_hdr_t
                       SET 
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= SYSDATE,
                        REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
                     WHERE LEARNING_MODULE_HDR_ID = p_trx_id;
                    COMMIT ;
                elsif upper('OVER_TIME_REQUEST')= upper(l_appr_process) THEN
                    update FS_OVER_TIME_HDR_T
                    set 
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= SYSDATE,
                        REQUEST_STATUS=FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
                        where 
                        OVER_TIME_HDR_ID=p_trx_id;
                    COMMIT ;
                    elsif upper('SITE_OVERTIME_REQUEST')= upper(l_appr_process) THEN
                    update FS_OVER_TIME_HDR_T
                    set 
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= SYSDATE,
                        REQUEST_STATUS=FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
                        where 
                        OVER_TIME_HDR_ID=p_trx_id;
                    COMMIT ;
                END IF;
        else
            --each level approval- updating in transaction table        
            IF upper('SELF_SERVICE')= upper(l_appr_process) then
                UPDATE fs_request_details
                   SET 
                    REQUEST_STATUS=l_pending_action_name,
                    LAST_UPDATED_BY=l_current_approver_emailid,
                    LAST_UPDATE_LOGIN=l_current_approver_emailid,
                    LAST_UPDATE_DATE= SYSDATE
                 WHERE REQUEST_ID = rec_action.transaction_id;
                COMMIT ;
--                elsif upper('VOLUNTARY_EXIT')= upper(l_appr_process) THEN
--                  UPDATE fs_request_details
--                   SET 
--                    REQUEST_STATUS=l_pending_action_name,
--                    LAST_UPDATED_BY=l_current_approver_emailid,
--                    LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                    LAST_UPDATE_DATE= SYSDATE
--                 WHERE REQUEST_ID = rec_action.transaction_id;
--                COMMIT ;
--                 elsif upper('FOOD_REQUEST')= upper(l_appr_process) THEN
--                  UPDATE fs_request_details
--                   SET 
--                    REQUEST_STATUS=l_pending_action_name,
--                    LAST_UPDATED_BY=l_current_approver_emailid,
--                    LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                    LAST_UPDATE_DATE= SYSDATE
--                 WHERE REQUEST_ID = rec_action.transaction_id;
--                COMMIT ;
--                elsif upper('SHUTDOWN_AND_EMERGENCY')= upper(l_appr_process) THEN
--                  UPDATE fs_request_details
--                   SET 
--                    REQUEST_STATUS=l_pending_action_name,
--                    LAST_UPDATED_BY=l_current_approver_emailid,
--                    LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                    LAST_UPDATE_DATE= SYSDATE
--                 WHERE REQUEST_ID = rec_action.transaction_id;
--                COMMIT ;
--                 elsif upper('MOVEMENT_FORM')= upper(l_appr_process) THEN
--                  UPDATE fs_request_details
--                   SET 
--                    REQUEST_STATUS=l_pending_action_name,
--                    LAST_UPDATED_BY=l_current_approver_emailid,
--                    LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                    LAST_UPDATE_DATE= SYSDATE
--                 WHERE REQUEST_ID = rec_action.transaction_id;
--                COMMIT ;
--                  elsif upper('JOB_ROTATION')= upper(l_appr_process) THEN
--                  UPDATE fs_request_details
--                   SET 
--                    REQUEST_STATUS=l_pending_action_name,
--                    LAST_UPDATED_BY=l_current_approver_emailid,
--                    LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                    LAST_UPDATE_DATE= SYSDATE
--                 WHERE REQUEST_ID = rec_action.transaction_id;
--                COMMIT ;
                elsif upper('LEARNING_REQUEST')= upper(l_appr_process) THEN
                    UPDATE fs_learning_module_hdr_t
                       SET 
                        REQUEST_STATUS=l_pending_action_name,
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= SYSDATE
                     WHERE LEARNING_MODULE_HDR_ID = p_trx_id;
                    COMMIT ;
                elsif upper('OVER_TIME_REQUEST')= upper(l_appr_process) THEN
                    update FS_OVER_TIME_HDR_T
                    set 
                        REQUEST_STATUS=l_pending_action_name,
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= SYSDATE
                        where 
                        OVER_TIME_HDR_ID=p_trx_id;
                    COMMIT ;
                    elsif upper('SITE_OVERTIME_REQUEST')= upper(l_appr_process) THEN
                    update FS_OVER_TIME_HDR_T
                    set 
                        REQUEST_STATUS=l_pending_action_name,
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= SYSDATE
                        where 
                        OVER_TIME_HDR_ID=p_trx_id;
                    COMMIT ;
                END IF;
        END IF;                                                                                                                                                                                                              --l_final_approver
      ELSIF p_action_code = 'FYI' THEN
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
                 AND faah.appr_level = (SELECT MIN(appr_level)
                                          FROM fs_approval_action_history_t
                                         WHERE action_id = rec_action.action_id
                                           AND appr_level > rec_action.approver_level)
            GROUP BY faah.appr_level
                    ,faah.appr_category_code;
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

         UPDATE fs_approval_action_history_t
            SET action_type_id = fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','NTY')
               ,action_date  = SYSDATE
               ,action_comments = NVL(p_comments, 'FYI')
          WHERE action_id = rec_action.action_id
            AND appr_level = rec_action.approver_level;
         commit;
         UPDATE fs_approval_action_t
            SET approver_user_id = l_approver_user_id
               ,approver_email_id = l_approver_email_address
               ,approver_level = l_approver_level
               ,approval_category_code = l_approver_category_code
                ,status_code  = CASE WHEN l_final_approver = 'Y' THEN 'A' ELSE 'O' END
          WHERE 
          status_code!='C'
          and action_id = rec_action.action_id;
          commit;

        IF l_final_approver = 'Y' THEN
            IF upper('SELF_SERVICE')= upper(l_appr_process) then
                UPDATE fs_approval_action_t
                SET approver_user_id = l_approver_user_id
                   ,approver_email_id = l_approver_email_address
                   ,approver_level = l_approver_level
                   ,approval_category_code = l_approver_category_code
                    ,status_code  = 'A'
                WHERE 
                1=1
                and action_id = rec_action.action_id;
                commit;
                --
                    UPDATE fs_request_details
                       SET 
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= systimestamp,
                         REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
                     WHERE REQUEST_ID = rec_action.transaction_id;
                    COMMIT ;
--                    elsif upper('VOLUNTARY_EXIT')= upper(l_appr_process) then
--                    UPDATE fs_request_details
--                       SET 
--                        LAST_UPDATED_BY=l_current_approver_emailid,
--                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                        LAST_UPDATE_DATE= systimestamp,
--                         REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
--                     WHERE REQUEST_ID = rec_action.transaction_id;
--                    COMMIT ;
--                      elsif upper('SHUTDOWN_AND_EMERGENCY')= upper(l_appr_process) then
--                    UPDATE fs_request_details
--                       SET 
--                        LAST_UPDATED_BY=l_current_approver_emailid,
--                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                        LAST_UPDATE_DATE= systimestamp,
--                         REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
--                     WHERE REQUEST_ID = rec_action.transaction_id;
--                    COMMIT ;
--                       elsif upper('FOOD_REQUEST')= upper(l_appr_process) then
--                    UPDATE fs_request_details
--                       SET 
--                        LAST_UPDATED_BY=l_current_approver_emailid,
--                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                        LAST_UPDATE_DATE= systimestamp,
--                         REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
--                     WHERE REQUEST_ID = rec_action.transaction_id;
--                    COMMIT ;
--                     elsif upper('MOVEMENT_FORM')= upper(l_appr_process) then
--                    UPDATE fs_request_details
--                       SET 
--                        LAST_UPDATED_BY=l_current_approver_emailid,
--                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                        LAST_UPDATE_DATE= systimestamp,
--                         REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
--                     WHERE REQUEST_ID = rec_action.transaction_id;
--                    COMMIT ;
--                       elsif upper('JOB_ROTATION')= upper(l_appr_process) then
--                    UPDATE fs_request_details
--                       SET 
--                        LAST_UPDATED_BY=l_current_approver_emailid,
--                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                        LAST_UPDATE_DATE= systimestamp,
--                         REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
--                     WHERE REQUEST_ID = rec_action.transaction_id;
--                    COMMIT ;
                elsif upper('LEARNING_REQUEST')= upper(l_appr_process) THEN
                    UPDATE fs_learning_module_hdr_t
                       SET 
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= systimestamp,
                        REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
                     WHERE LEARNING_MODULE_HDR_ID = p_trx_id;
                    COMMIT ;
                elsif upper('OVER_TIME_REQUEST')= upper(l_appr_process) THEN
                    update FS_OVER_TIME_HDR_T
                    set 
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= systimestamp,
                        REQUEST_STATUS=FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
                        where 
                        OVER_TIME_HDR_ID=p_trx_id;
                    COMMIT ;
                    elsif upper('SITE_OVERTIME_REQUEST')= upper(l_appr_process) THEN
                    update FS_OVER_TIME_HDR_T
                    set 
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= systimestamp,
                        REQUEST_STATUS=FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
                        where 
                        OVER_TIME_HDR_ID=p_trx_id;
                    COMMIT ;
                END IF;
        else
            --each level approval update in transaction table        
            IF upper('SELF_SERVICE')= upper(l_appr_process) then
                    UPDATE fs_request_details
                       SET 
                        REQUEST_STATUS=l_pending_action_name,
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= systimestamp
                     WHERE REQUEST_ID = rec_action.transaction_id;
                    COMMIT ;
--                    elsif upper('MOVEMENT_FORM')= upper(l_appr_process) then
--                    UPDATE fs_request_details
--                       SET 
--                        REQUEST_STATUS=l_pending_action_name,
--                        LAST_UPDATED_BY=l_current_approver_emailid,
--                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                        LAST_UPDATE_DATE= systimestamp
--                     WHERE REQUEST_ID = rec_action.transaction_id;
--                    COMMIT ;
--                    elsif upper('VOLUNTARY_EXIT')= upper(l_appr_process) then
--                    UPDATE fs_request_details
--                       SET 
--                        REQUEST_STATUS=l_pending_action_name,
--                        LAST_UPDATED_BY=l_current_approver_emailid,
--                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                        LAST_UPDATE_DATE= systimestamp
--                     WHERE REQUEST_ID = rec_action.transaction_id;
--                    COMMIT ;
--                     elsif upper('FOOD_REQUEST')= upper(l_appr_process) then
--                    UPDATE fs_request_details
--                       SET 
--                        REQUEST_STATUS=l_pending_action_name,
--                        LAST_UPDATED_BY=l_current_approver_emailid,
--                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                        LAST_UPDATE_DATE= systimestamp
--                     WHERE REQUEST_ID = rec_action.transaction_id;
--                    COMMIT ;
--                     elsif upper('SHUTDOWN_AND_EMERGENCY')= upper(l_appr_process) then
--                    UPDATE fs_request_details
--                       SET 
--                        REQUEST_STATUS=l_pending_action_name,
--                        LAST_UPDATED_BY=l_current_approver_emailid,
--                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                        LAST_UPDATE_DATE= systimestamp
--                     WHERE REQUEST_ID = rec_action.transaction_id;
--                    COMMIT ;
--                     elsif upper('JOB_ROTATION')= upper(l_appr_process) then
--                    UPDATE fs_request_details
--                       SET 
--                        REQUEST_STATUS=l_pending_action_name,
--                        LAST_UPDATED_BY=l_current_approver_emailid,
--                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                        LAST_UPDATE_DATE= systimestamp
--                     WHERE REQUEST_ID = rec_action.transaction_id;
--                    COMMIT ;
                elsif upper('LEARNING_REQUEST')= upper(l_appr_process) THEN
                    UPDATE fs_learning_module_hdr_t
                       SET 
                        REQUEST_STATUS=l_pending_action_name,
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= systimestamp
                     WHERE LEARNING_MODULE_HDR_ID = p_trx_id;
                    COMMIT ;
                elsif upper('OVER_TIME_REQUEST')= upper(l_appr_process) THEN
                    update FS_OVER_TIME_HDR_T
                    set 
                        REQUEST_STATUS=l_pending_action_name,
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= systimestamp
                        where 
                        OVER_TIME_HDR_ID=p_trx_id;
                    COMMIT ;
                    elsif upper('SITE_OVERTIME_REQUEST')= upper(l_appr_process) THEN
                    update FS_OVER_TIME_HDR_T
                    set 
                        REQUEST_STATUS=l_pending_action_name,
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= systimestamp
                        where 
                        OVER_TIME_HDR_ID=p_trx_id;
                    COMMIT ;
                END IF;
        END IF;
      ELSIF p_action_code = 'REJECT' THEN
         UPDATE fs_approval_action_history_t
            SET 
            action_type_id = CASE
                                 WHEN appr_level = rec_action.approver_level THEN
                                       CASE
                                          WHEN response_user_id = l_action_user_id THEN
                                             fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','REJECT')
                                          ELSE
                                             fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','BEATEN')
                                       END
                                    ELSE
                                       fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','CLOSED')
                                 END,
               action_date  = CASE
                                  WHEN (appr_level = rec_action.approver_level
                                    AND response_user_id = l_action_user_id) THEN
                                     SYSDATE
                                  ELSE
                                     --NULL [30-Jul-23]
                                     SYSDATE
                               END
               ,action_comments = CASE
                                     WHEN (appr_level = rec_action.approver_level
                                       AND response_user_id = l_action_user_id) THEN
                                        p_comments
                                     ELSE
                                       NULL 
                                       -- p_comments
                                  END
          WHERE action_id = rec_action.action_id
            AND appr_level >= rec_action.approver_level;
         COMMIT;
         UPDATE fs_approval_action_t
            SET approver_user_id = NULL
               ,approver_email_id = NULL
               ,approver_level = NULL
               ,approval_category_code = NULL
               ,status_code  = 'R'
          WHERE action_id = rec_action.action_id;
        COMMIT;
        --each level approval updating in transaction table        
          IF upper('SELF_SERVICE')= upper(l_appr_process) then
                UPDATE fs_request_details
                   SET 
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                    LAST_UPDATE_DATE= SYSDATE,
                     REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','REJECT')
                 WHERE REQUEST_ID = rec_action.transaction_id;
                COMMIT ;  
--                elsif upper('MOVEMENT_FORM')= upper(l_appr_process) then
--                UPDATE fs_request_details
--                   SET 
--                        LAST_UPDATED_BY=l_current_approver_emailid,
--                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                    LAST_UPDATE_DATE= SYSDATE,
--                     REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','REJECT')
--                 WHERE REQUEST_ID = rec_action.transaction_id;
--                COMMIT ;
--                elsif upper('FOOD_REQUEST')= upper(l_appr_process) then
--                UPDATE fs_request_details
--                   SET 
--                        LAST_UPDATED_BY=l_current_approver_emailid,
--                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                    LAST_UPDATE_DATE= SYSDATE,
--                     REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','REJECT')
--                 WHERE REQUEST_ID = rec_action.transaction_id;
--                COMMIT ;
--                elsif upper('VOLUNTARY_EXIT')= upper(l_appr_process) then
--                UPDATE fs_request_details
--                   SET 
--                        LAST_UPDATED_BY=l_current_approver_emailid,
--                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                    LAST_UPDATE_DATE= SYSDATE,
--                     REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','REJECT')
--                 WHERE REQUEST_ID = rec_action.transaction_id;
--                COMMIT ;
--                elsif upper('SHUTDOWN_AND_EMERGENCY')= upper(l_appr_process) then
--                UPDATE fs_request_details
--                   SET 
--                        LAST_UPDATED_BY=l_current_approver_emailid,
--                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                    LAST_UPDATE_DATE= SYSDATE,
--                     REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','REJECT')
--                 WHERE REQUEST_ID = rec_action.transaction_id;
--                COMMIT ;
--                   elsif upper('JOB_ROTATION')= upper(l_appr_process) then
--                UPDATE fs_request_details
--                   SET 
--                        LAST_UPDATED_BY=l_current_approver_emailid,
--                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
--                    LAST_UPDATE_DATE= SYSDATE,
--                     REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','REJECT')
--                 WHERE REQUEST_ID = rec_action.transaction_id;
--                COMMIT ;
                elsif upper('LEARNING_REQUEST')= upper(l_appr_process) THEN
                    UPDATE fs_learning_module_hdr_t
                       SET 
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= SYSDATE,
                        REQUEST_STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','REJECT')
                     WHERE LEARNING_MODULE_HDR_ID = p_trx_id;
                    COMMIT ;
                elsif upper('OVER_TIME_REQUEST')= upper(l_appr_process) THEN
                      update FS_OVER_TIME_HDR_T
                    set 
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= SYSDATE,
                        REQUEST_STATUS=FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','REJECT')
                        where 
                        OVER_TIME_HDR_ID=p_trx_id;
                    COMMIT ;
                     elsif upper('SITE_OVERTIME_REQUEST')= upper(l_appr_process) THEN
                      update FS_OVER_TIME_HDR_T
                    set 
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= SYSDATE,
                        REQUEST_STATUS=FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','REJECT')
                        where 
                        OVER_TIME_HDR_ID=p_trx_id;
                    COMMIT ;
                END IF;
      ELSIF p_action_code = 'MOREINFO' THEN
         NULL;
      END IF;

      p_error_code := l_error_code;
      p_error_msg := l_error_msg||'==>'||rec_action.action_id||'==>'||rec_action.approver_level;
   END update_action;



--   PROCEDURE get_approval_detail(
--        p_appr_process    IN VARCHAR2
--      , p_trx_id          IN VARCHAR2
--      , p_result          out SYS_REFCURSOR   
--    )
--    is
--            l_transaction_number varchar2(60);
--            l_screen_name varchar2(60);
--            l_app_type varchar2(60);
--            l_attribute1 varchar2(120);
--            l_attribute2 varchar2(120);
--            l_attribute3 varchar2(120);
--            l_attribute4 varchar2(120);
--            l_attribute5 varchar2(120);
--            l_page varchar2(120);
--            l_shell varchar2(120);
--            l_flow varchar2(120);
--
--    cur_data         SYS_REFCURSOR;
--    items           SYS_REFCURSOR;
--
--    BEGIN    
--
--        if UPPER(p_appr_process) =upper('APPLICATION') then 
--            SELECT 
--            APPLICATION_NUMBER , HEADER_ID, CONT_HEADER_ID, REVISION_NUM  
--            into
--            l_transaction_number, l_attribute1, l_attribute3, l_attribute4
--            FROM sc_application_headers_t
--            where 
--            HEADER_ID=p_trx_id;
--            l_screen_name:='Application';    
--            l_app_type:='APPLICATION';
--            l_attribute2:='Edit';
--            l_page :='shell';
--            l_shell:='application';
--            l_flow:='application-page';
--        elsif UPPER(p_appr_process) =upper('CERTIFICATION') then 
--            SELECT 
--            CERTIFICATION_NUMBER , HEADER_ID, CONT_HEADER_ID, REVISION_NUM
--            into 
--            l_transaction_number, l_attribute1, l_attribute3, l_attribute4
--            FROM sc_certification_headers_t
--            where 
--            HEADER_ID=p_trx_id;
--            l_screen_name:='Certification';    
--            l_app_type:='CERTIFICATION';
--            l_attribute2:='Edit';
--            l_page :='shell';
--            l_shell:='certification';
--            l_flow:='certification-page';
--
--
--          --  24/04/23
--
--              elsif UPPER(p_appr_process) =upper('CONTRACT') then 
--            SELECT 
--             CONTRACT_NUM, BU_ID, HEADER_ID, REVISION_NUM , CONTRACT_NUM
--            into 
--            l_transaction_number,l_attribute1, l_attribute3, l_attribute4, l_attribute5
--            FROM sc_contract_headers_t
--            where 
--            HEADER_ID=p_trx_id;
--            l_screen_name:='Contract';
--            l_app_type:='CONTRACT';
--            l_attribute2:='EDIT';
--            l_page :='shell';
--            l_shell:='contract';
--            l_flow:='contract-page';
--
--             elsif UPPER(p_appr_process) =upper('RETENTION_RELEASE') then 
--            SELECT 
--            RET_REL_NUMBER , HEADER_ID, CONT_HEADER_ID
--            into 
--            l_transaction_number, l_attribute1, l_attribute3
--            FROM sc_ret_release_headers_t
--            where 
--            HEADER_ID=p_trx_id;
--            l_screen_name:='Retention Release';    
--            l_app_type:='RETENTION_RELEASE';
--            l_attribute2:='Edit';
--            l_page :='shell';
--            l_shell:='retention-release';
--            l_flow:='retention-release-add-edit';
--
--        end if;
--
--
--    l_error_code := 'S';
--    l_error_msg := 'Successfully Updated';
--
--    OPEN items
--    FOR 
--        SELECT
--            'Action Required: Approval of '||l_screen_name||' Request for '||l_screen_name||':'||l_transaction_number as l_subject,
--            l_error_code as l_error_code,
--            l_error_msg as l_error_msg,
--            l_app_type AS l_app_type,
--            l_attribute1 as l_attribute1,   -- hdrid
--            l_attribute2 as l_attribute2,   -- page edit
--            l_attribute3 as l_attribute3,   -- contracthdrId
--            l_attribute4 as l_attribute4,   -- revision
--            l_attribute5 as l_attribute5,   --
--            l_page as l_page,
--            l_shell as l_shell,
--            l_flow as l_flow
--        from dual;
----    CLOSE cur_data;
--
--    p_result:=items;
----
--    END get_approval_detail;
--

END fs_approval_process_pkg;
/
