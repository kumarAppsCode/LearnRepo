CREATE OR REPLACE PACKAGE fs_approval_process_travel_pkg
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




END fs_approval_process_travel_pkg;
/


CREATE OR REPLACE PACKAGE BODY fs_approval_process_travel_pkg
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
        ROWNUM=1 AND 
        TRANSACTION_ID=p_trx_id;

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

    SELECT * FROM 
    (
        SELECT
            fah.appr_hierarchy_id,
            fah.appr_request_id,
            fah.appr_request_code,
            fah.appr_request_name,
            fah.appr_category_id,
            fah.appr_category_code,
            fah.appr_category_name,
            fah.appr_type_id,
            fah.appr_type_code,
            fah.appr_type_name,
            fah.appr_level,
            fah.appr_role_id,
            fah.appr_role_code appr_role_code,
            fah.appr_role_name appr_role_name,
            (
                CASE
                    WHEN fah.appr_role_code = 'LINE_MANAGER_BASE' THEN
                        (
                            SELECT
                                nvl(MAX(ass.supervisor_id), 100000003250056)
                            FROM
                                fs_assignment_stg_t ass
                            WHERE
                                    ass.person_id = p_person_id
                                AND ass.last_update_date = (
                                    SELECT
                                        MAX(asst.last_update_date)
                                    FROM
                                        fs_assignment_stg_t asst
                                    WHERE
                                        asst.person_id = p_person_id
                                )
                                AND ROWNUM = 1
                        )
                    WHEN fah.appr_role_code = 'LINE_MANAGER_2'    THEN
                        (
                            SELECT
                                nvl(MAX(ass.supervisor_id), 100000003250056)
                            FROM
                                fs_assignment_stg_t ass
                            WHERE
                                    ass.person_id = p_person_id
                                AND ass.last_update_date = (
                                    SELECT
                                        MAX(asst.last_update_date)
                                    FROM
                                        fs_assignment_stg_t asst
                                    WHERE
                                        asst.person_id = p_person_id
                                )
                                AND ROWNUM = 1
                        )
                    WHEN fah.appr_role_code = 'DEPARTMENT_BASE'   THEN
                        (
                            SELECT
                                to_number(xxnws_get_org_manager(p_person_id, 'DEPT', 'PERSON_ID', sysdate))
                            FROM
                                dual
                        )
                    WHEN fah.appr_role_code IN ('EMPLOYEE_GM','GM_EMPLOYEE_DIVISION', 'DEPARTMENT_GM', 'TNI_DIV_GM', 'VEC_GM_DIV_APPROVAL_GROUP' )
                    THEN
                        (
                            SELECT
                                to_number(nvl(nvl(xxnws_get_org_manager(p_person_id, 'DIV', 'PERSON_ID', sysdate), xxnws_get_org_manager(
                                p_person_id, 'DIR', 'PERSON_ID', sysdate)), xxnws_get_org_manager(p_person_id, 'SD_DIR', 'PERSON_ID',
                                sysdate)))
                            FROM
                                dual
                        )
                    ELSE
                        fah.appr_user_id
                END
            )                  AS appr_user_id
        FROM
            fs_approval_hierarchy_dtl_v fah
        WHERE
              upper(fah.appr_request_code) =fs_get_travel_approval_group(p_appr_process, p_person_id) 
--              fah.appr_request_code = p_appr_process
--              fah.appr_request_code = 'BUSINESS_OFFICIAL_MISSION_OVERSEAS'
--              fah.appr_request_code = 'BUSINESS_SEMINAR_OMAN'
            AND fah.appr_level > 0
            AND UPPER(fah.appr_role_code) NOT like ('TRAVEL_SECTION%')
UNION ALL
SELECT
            fah.appr_hierarchy_id,
            fah.appr_request_id,
            fah.appr_request_code,
            fah.appr_request_name,
            fah.appr_category_id,
            fah.appr_category_code,
            fah.appr_category_name,
            fah.appr_type_id,
            fah.appr_type_code,
            fah.appr_type_name,
            fah.appr_level,
            fah.appr_role_id,
            fah.appr_role_code appr_role_code,
            fah.appr_role_name appr_role_name,
            fah.appr_user_id AS appr_user_id
        FROM
            fs_approval_hierarchy_dtl_v fah
        WHERE
                upper(fah.appr_request_code) =fs_get_travel_approval_group(p_appr_process, p_person_id) 
--                fah.appr_request_code = p_appr_process
--              fah.appr_request_code = 'BUSINESS_OFFICIAL_MISSION_OVERSEAS'
--              fah.appr_request_code = 'BUSINESS_SEMINAR_OMAN'

            AND fah.appr_level > 0
            AND UPPER(fah.appr_role_code) NOT like ('TRAVEL_SECTION_%2')
            AND UPPER(fah.appr_role_code) like ('TRAVEL_SECTION_%')
            and fah.appr_role_code in (select xxnws_get_travel_region_appr(p_appr_process,p_person_id) FROM dual)
UNION ALL
SELECT
            fah.appr_hierarchy_id,
            fah.appr_request_id,
            fah.appr_request_code,
            fah.appr_request_name,
            fah.appr_category_id,
            fah.appr_category_code,
            fah.appr_category_name,
            fah.appr_type_id,
            fah.appr_type_code,
            fah.appr_type_name,
            fah.appr_level,
            fah.appr_role_id,
            fah.appr_role_code appr_role_code,
            fah.appr_role_name appr_role_name,
            fah.appr_user_id AS appr_user_id
        FROM
            fs_approval_hierarchy_dtl_v fah
        WHERE
                upper(fah.appr_request_code) =fs_get_travel_approval_group(p_appr_process, p_person_id) 
--                fah.appr_request_code = p_appr_process
--                fah.appr_request_code = 'BUSINESS_OFFICIAL_MISSION_OVERSEAS'
--                fah.appr_request_code = 'BUSINESS_SEMINAR_OMAN'
            AND fah.appr_level > 0
            AND UPPER(fah.appr_role_code) like ('TRAVEL_SECTION_%2')
            and fah.appr_role_code in (select xxnws_get_travel_region_appr(p_appr_process,p_person_id)||'2' FROM dual)
)
where 
1=1
AND appr_user_id is not null  
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
      l_open_tx_count number:=0;  

      --S==>[25-oct-duplicate logic change]
      l_new_APPROVER_ACTION_COMMENTS varchar2(240):=null;
      l_new_APPROVER_ACTION_CODE varchar2(240):=null;
      l_new_APPROVER_ACTION_TYPE_ID number:=null;
      l_version number:=0;
      l_role_id number;    

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


      IF (l_error_code = 'S'and l_open_tx_count=0) THEN
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
            --31-Dec-2023==>login user and approver same - approval skipe            
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
                        ,rec_appr.appr_user_id                         --response_user_id
                        ,lv_ACTION_TYPE_ID                             --action_type_id
--                      ,lv_new_action_type_id                         --action_type_id  [25-oct-duplicate logic change]
                        ,rec_appr.appr_role_id
                        ,lv_ACTION_DATE                               --action_date
                        ,lv_ACTION_COMMENTS                           --action_comments
                        ,p_user_id                                    --created_by
                        ,SYSDATE                                      --creation_date
                        ,p_user_id                                    --last_updated_by
                        ,SYSDATE                                      --last_update_date
                        ,p_user_id                                    --last_update_login
                        ,lv_ACTION_COMMENTS
                        ,lv_APPROVER_ACTION_CODE
                        ,lv_APPROVER_ACTION_TYPE_ID
                         );
                    commit;
            --     DBMS_OUTPUT.put_line ('l_action_sequence_num >> ' || l_action_sequence_num);
                        l_new_APPROVER_ACTION_COMMENTS:=null;
                        l_new_APPROVER_ACTION_CODE:=null;
                        l_new_APPROVER_ACTION_TYPE_ID:=null;


            IF l_action_sequence_num = 10 THEN
               l_appr_level_f := rec_appr.appr_level;
               l_approver_category_code := rec_appr.appr_category_code;
            END IF;

            -- DBMS_OUTPUT.put_line ('l_appr_level_f >> ' || l_appr_level_f);

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

            IF upper('TRAVEL_REQUEST')= upper(l_appr_process) THEN
                UPDATE fs_travel_header_t
                   SET 
                    APPROVAL_DEPARTMENT=fs_get_travel_approval_group(p_appr_process, p_user_id), 
                    LAST_UPDATE_DATE= SYSDATE,
                    TRAVEL_STATUS_ID = FS_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','PENDING'),
                    STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','PENDING')
                 WHERE TRAVEL_HEADER_ID = p_trx_id;
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
      l_current_approver_emailid VARCHAR2(240);
      l_pending_action_id number:=fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION', 'PENDING');
      l_approve_action_id number:=fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION', 'APPROVE'); 
      l_reject_action_id number:=fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION', 'REJECT');      
      l_close_action_id number:=fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','CLOSED');      
      l_beaten_action_id number:=fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION','BEATEN');
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
        and APPR_LEVEL=ll_app_level
        and APPROVER_ACTION_CODE='APPROVE'
          --Added by Manoj for approval Skip
        ;

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

        --approval process name [module name]
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
        --approval process name [module name]
        begin
        SELECT 
            APPROVER_EMAIL_ID 
            into 
            l_current_approver_emailid
            FROM fs_approval_action_history_t
            where 
            1=1
            AND APPROVER_EMAIL_ID IS NOT NULL
            and APPROVER_ACTION_DATE is not null
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
                DBMS_OUTPUT.PUT_LINE('==>'||p_action_id);
                DBMS_OUTPUT.PUT_LINE('==>'||rec_action.approver_level);
                DBMS_OUTPUT.PUT_LINE('==>'||c1.RESPONSE_USER_ID);
                DBMS_OUTPUT.PUT_LINE('l_pending_action_id==>'||l_pending_action_id);
                DBMS_OUTPUT.PUT_LINE('ACTION_HISTORY_ID==>'||c2.ACTION_HISTORY_ID);
                update fs_approval_action_history_t
                set 
                    ACTION_TYPE_ID=l_close_action_id, 
                    ACTION_DATE=systimestamp, 
                    ACTION_COMMENTS='Approval Skipped',
                    APPROVER_ACTION_DATE=systimestamp, 
                    APPROVER_ACTION_COMMENTS='Approval Skipped', 
                    APPROVER_EMAIL_ID=null, 
                    APPROVER_USER_ID=null, 
                    APPROVER_ACTION_CODE='CLOSED', 
                    APPROVER_ACTION_TYPE_ID=l_close_action_id,
                    LAST_UPDATE_DATE=systimestamp,
                    LAST_UPDATE_LOGIN=c2.RESPONSE_USER_ID
                where 
                    1=1
--                  and ACTION_DATE is null
--                  and APPR_CATEGORY_ID=l_emp_category_id
--                  and RESPONSE_USER_ID=c1.RESPONSE_USER_ID
--                  and NVL(APPROVER_ACTION_TYPE_ID,ACTION_TYPE_ID) =l_pending_action_id
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
                                           AND ACTION_TYPE_ID=fs_utility_pkg.get_lookup_value_id('APPROVAL_ACTION', 'PENDING')
                                           AND appr_level > rec_action.approver_level)
             group by faah.appr_level, faah.appr_category_code;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_approver_level := -1;
               l_approver_category_code := NULL;
               l_approver_user_id := NULL;
               l_approver_email_address := NULL;
               l_final_approver := 'Y';
            WHEN OTHERS THEN
               l_error_code := 'E';
               l_error_msg := 'API Error';
         END;

DBMS_OUTPUT.PUT_LINE('==>'||l_action_user_id);
DBMS_OUTPUT.PUT_LINE('l_final_approver==>'||l_final_approver);
DBMS_OUTPUT.PUT_LINE('==>'||rec_action.action_id);
DBMS_OUTPUT.PUT_LINE('==>'||rec_action.approver_level);

         UPDATE fs_approval_action_history_t
            SET action_type_id = CASE
                                    WHEN response_user_id = l_action_user_id THEN
                                       l_approve_action_id
                                    ELSE
                                       l_beaten_action_id
                                 END
               ,action_date  = CASE WHEN response_user_id = l_action_user_id THEN SYSDATE ELSE null END 
               ,action_comments = CASE WHEN response_user_id = l_action_user_id THEN p_comments ELSE null END  
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
          1=1
          and status_code!='C'
          and action_id = rec_action.action_id;
            commit;

         IF l_final_approver = 'Y' THEN
            IF upper('TRAVEL_REQUEST')= upper(l_appr_process) THEN
                    UPDATE fs_travel_header_t
                       SET 
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= SYSDATE,
                        TRAVEL_STATUS_ID = l_approve_action_id,
                        STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
                     WHERE 
                     1=1
                     and TRAVEL_STATUS_ID = l_pending_action_id
                     and TRAVEL_HEADER_ID = p_trx_id;
                    COMMIT ;
            END IF;
        else
            --each level approval- updating in transaction table        
            IF upper('TRAVEL_REQUEST')= upper(l_appr_process) THEN
                    UPDATE fs_travel_header_t
                       SET 
                        TRAVEL_STATUS_ID = l_pending_action_id,
                        STATUS=FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','PENDING'),
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= SYSDATE
                     WHERE TRAVEL_HEADER_ID = p_trx_id;
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
--                                          AND ACTION_TYPE_ID=l_pending_action_id
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
          --,status_code              = CASE WHEN l_final_approver = 'Y' THEN 'A' ELSE 'O' END
          WHERE action_id = rec_action.action_id;
          commit;

        IF l_final_approver = 'Y' THEN
            IF upper('TRAVEL_REQUEST')= upper(l_appr_process) THEN
                    UPDATE fs_travel_header_t
                       SET 
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= systimestamp,
                        TRAVEL_STATUS_ID = l_approve_action_id,
                       STATUS = FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','APPROVE')
                     WHERE 
                     1=1
                     and TRAVEL_STATUS_ID = l_pending_action_id
                     and TRAVEL_HEADER_ID = p_trx_id;
                    COMMIT ;
                END IF;
        else
            --each level approval update in transaction table        
            IF upper('TRAVEL_REQUEST')= upper(l_appr_process) THEN
                    UPDATE fs_travel_header_t
                       SET 
                        TRAVEL_STATUS_ID = l_pending_action_id,
                        STATUS=FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','PENDING'),
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= systimestamp
                     WHERE TRAVEL_HEADER_ID = p_trx_id;
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
                                             l_reject_action_id
                                          ELSE
                                             l_beaten_action_id
                                       END
                                    ELSE
                                       l_close_action_id
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
                                        --NULL [30-Jul-23]
                                        --p_comments
                                        null
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
          IF upper('TRAVEL_REQUEST')= upper(l_appr_process) THEN
                    UPDATE fs_travel_header_t
                       SET 
                        LAST_UPDATED_BY=l_current_approver_emailid,
                        LAST_UPDATE_LOGIN=l_current_approver_emailid,
                        LAST_UPDATE_DATE= SYSDATE,
                        TRAVEL_STATUS_ID = l_reject_action_id,
                        STATUS=FS_utility_pkg.get_lookup_value_name('APPROVAL_ACTION','REJECT')
                     WHERE TRAVEL_HEADER_ID = p_trx_id;
                    COMMIT ; 

                END IF;
      ELSIF p_action_code = 'MOREINFO' THEN
         NULL;
      END IF;

      p_error_code := l_error_code;
      p_error_msg := l_error_msg||'==>'||rec_action.action_id||'==>'||rec_action.approver_level;
   END update_action;


END fs_approval_process_travel_pkg;
/
