CREATE OR REPLACE package  XXQIA_ADMIN_INV_APPROVAL_PKG
is
procedure submit_action(
     p_primary_id       IN      NUMBER
    ,p_table_name       IN      VARCHAR2
    ,p_login_user       IN      VARCHAR2
    ,p_err_code         OUT      VARCHAR2
    ,p_err_msg          OUT      VARCHAR2
);



procedure update_action(
	 p_primary_id       IN       VARCHAR2
    ,p_table_name       IN       VARCHAR2
	,p_login_user       IN       VARCHAR2
    ,p_request_type     IN       VARCHAR2
	,p_appr_id			IN       VARCHAR2
    ,p_appr_level       IN       VARCHAR2
	,p_response			IN       VARCHAR2
	,p_ar_status		IN       VARCHAR2
    ,p_seq              OUT      VARCHAR2
    ,p_err_code         OUT      VARCHAR2
    ,p_err_msg          OUT      VARCHAR2
    ,p_flow_status      OUT      VARCHAR2
);


end XXQIA_ADMIN_INV_APPROVAL_PKG;
/


CREATE OR REPLACE PACKAGE BODY XXQIA_ADMIN_INV_APPROVAL_PKG 
IS

procedure submit_action(
     p_primary_id       IN      NUMBER
    ,p_table_name       IN      VARCHAR2
    ,p_login_user       IN      VARCHAR2
    ,p_err_code         OUT      VARCHAR2
    ,p_err_msg          OUT      VARCHAR2
)IS

cursor submit_cursor
is
select * from 
(
        SELECT
            applv_val  as approver_user_id,
            'Approver' category,
            'INV_APVL' role_name,
            ROWNUM    approver_level
        FROM
            xxqia_admin_invoice_hdr UNPIVOT ( applv_val
                FOR applv
            IN ( 
                 department_approver,
                 approver1,
                 approver2,
                 approver3,
                 approver4,
                 approver5 ) ) unpvt
        WHERE
          REQUEST_ID = p_primary_id
union all 
        SELECT
            to_number(trim(lk.LOOKUP_VALUE_CODE)) AS approver_user_id,
            ah.category,
            ah.role_name,
            ah.approver_level
--            ,ah.enabled_flag,
--            ah.header_id,
--            ah.approval_request_type,
        FROM
            xxqia_approval_hierarchy ah,
            xxfnd_lookup_v           lk
        WHERE
                upper(nvl(ah.role_name, 'XXX')) = upper(nvl(lk.lookup_type_code, 'XXX'))
        --AND lk.LOOKUP_TYPE_CODE='QIA_POINV_FINANCE_REVIEW'
            AND ah.approval_request_type LIKE 'INVOICE'
)
where approver_level = (
SELECT
    MIN(approver_level)
FROM
    (
        SELECT
             applv_val  as  approver_user_id,
            'Approver' category,
            'INV_APVL' role_name,
            ROWNUM     approver_level
        FROM
            xxqia_admin_invoice_hdr UNPIVOT ( applv_val
                FOR applv
            IN ( department_approver,
                 approver1,
                 approver2,
                 approver3,
                 approver4,
                 approver5 ) ) unpvt
        WHERE
            request_id = p_primary_id
        UNION ALL
        SELECT
            to_number(trim(lk.LOOKUP_VALUE_CODE))  AS approver_user_id,
            ah.category,
            ah.role_name,
            ah.approver_level
        FROM
            xxqia_approval_hierarchy ah,
            xxfnd_lookup_v           lk
        WHERE
                upper(nvl(ah.role_name, 'XXX')) = upper(nvl(lk.lookup_type_code, 'XXX'))
            AND ah.approval_request_type LIKE 'INVOICE'
    )
WHERE
    approver_level NOT IN (
        SELECT
            nvl(action_level, 0)
        FROM
            xxqia_approval_action_history_t
        WHERE
            transaction_id = p_primary_id
    )
)
order by approver_level;


cursor header_cursor
is 
SELECT * FROM xxqia_admin_invoice_hdr
where 
REQUEST_ID=p_primary_id;

header_ref_cursor          header_cursor%ROWTYPE;
lv_request_status        VARCHAR2(150) := 'Pending';
lv_status                VARCHAR2(10) := 'S';
lv_login_approver_count        number;   
lv_seq                      number:=0;

lv_next_level               number;
lapplevel                NUMBER;
lappuserid               VARCHAR2(240);
lappemail                VARCHAR2(240);
lapppernumber            XXQIA_ADMIN_INVOICE_HDR.approver_number%TYPE;
lv_category              XXQIA_ADMIN_INVOICE_HDR.category%TYPE;



begin
if(lv_status='S') then 

open header_cursor;
fetch header_cursor into header_ref_cursor;
close header_cursor;

FOR c0 in submit_cursor
loop
--
lv_next_level:=c0.approver_user_id;
DBMS_OUTPUT.PUT_LINE('lv_next_level==>'||lv_next_level);
--
--login user and approver are same then count 1
if(p_login_user=c0.approver_user_id)then 
    lv_login_approver_count:=1;
end if;
DBMS_OUTPUT.PUT_LINE('lv_login_approver_count'||lv_login_approver_count);

                BEGIN
                    INSERT INTO xxqia_approval_action_history_t (
                        action_history_id,
                        object_version_number,
                        transaction_source,
                        transaction_type,
                        transaction_id,
                        transaction_num,
                        action_sequence_num,
                        action_code,
                        requester_user_id,
                        response_user_id,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        action_level,
                        submission_date,
                        category,
                        ACTION_DATE,
                        ACTION_COMMENTS
                    ) VALUES (
                        xxfnd_request_details_s.NEXTVAL,
                        NVL(header_ref_cursor.OBJECT_VERSION_NUMBER, 0),
                        'INVOICE',
                        'INVOICE',
                        p_primary_id,
                        header_ref_cursor.REQUEST_NUMBER,
                        c0.approver_level,
                        case 
                        when upper(c0.role_name)='AUTO' THEN 'Approved'
                        when lv_login_approver_count=1 THEN 'Approved'
                        else 'Pending'
                        end,
--                      decode(c0.role_name, 'AUTO', 'Approved', ),
                        p_login_user,
                        c0.approver_user_id,
                        p_login_user,
                        sysdate,
                        p_login_user,
                        sysdate,
                        p_login_user,
                        c0.approver_level,
                        sysdate,
                        c0.category,
                        case 
                        when upper(c0.role_name)='AUTO' THEN sysdate
                        when lv_login_approver_count=1 THEN sysdate
                        else null
                        end,
                        case 
                        when upper(c0.role_name)='AUTO' THEN 'Auto Approved'
                        when lv_login_approver_count=1 THEN 'Approval Skipped'
                        else null
                        end
                    );
                COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        dbms_output.put_line('Exception ==' || sqlerrm);
                    p_err_code:='E';
                    p_err_msg:='Error in Insert History';
                END;

end loop;

if(lv_login_approver_count=1) then 
DBMS_OUTPUT.PUT_LINE('level approved and 2nd level inserted');
--1st submit approved and check next level
FOR c10 in submit_cursor
loop
--
lv_next_level:=c10.approver_level;
DBMS_OUTPUT.PUT_LINE('lv_next_level==>'||lv_next_level);
--
--login user and approver are same then count 1
DBMS_OUTPUT.PUT_LINE('p_login_user==>'||p_login_user);
DBMS_OUTPUT.PUT_LINE('c10.approver_user_id==>'||c10.approver_user_id);
if(p_login_user=c10.approver_user_id)then 
    lv_login_approver_count:=1;
else
lv_login_approver_count:=0;
end if;
DBMS_OUTPUT.PUT_LINE('lv_login_approver_count'||lv_login_approver_count);

                BEGIN
                    INSERT INTO xxqia_approval_action_history_t (
                        action_history_id,
                        object_version_number,
                        transaction_source,
                        transaction_type,
                        transaction_id,
                        transaction_num,
                        action_sequence_num,
                        action_code,
                        requester_user_id,
                        response_user_id,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        action_level,
                        submission_date,
                        category,
                        ACTION_DATE,
                        ACTION_COMMENTS
                    ) VALUES (
                        xxfnd_request_details_s.NEXTVAL,
                        NVL(header_ref_cursor.OBJECT_VERSION_NUMBER, 0),
                        'INVOICE',
                        'INVOICE',
                        p_primary_id,
                        header_ref_cursor.REQUEST_NUMBER,
                        c10.approver_level,
                        case 
                        when upper(c10.role_name)='AUTO' THEN 'Approved'
                        when lv_login_approver_count=1 THEN 'Approved'
                        else 'Pending'
                        end,
--                      decode(c0.role_name, 'AUTO', 'Approved', ),
                        p_login_user,
                        c10.approver_user_id,
                        p_login_user,
                        sysdate,
                        p_login_user,
                        sysdate,
                        p_login_user,
                        c10.approver_level,
                        sysdate,
                        c10.category,
                        case 
                        when upper(c10.role_name)='AUTO' THEN sysdate
                        when lv_login_approver_count=1 THEN sysdate
                        else null
                        end,
                        case 
                        when upper(c10.role_name)='AUTO' THEN 'Auto Approved'
                        when lv_login_approver_count=1 THEN 'Approval Skipped'
                        else null
                        end
                    );
                COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        dbms_output.put_line('Exception ==' || sqlerrm);
                    p_err_code:='E';
                    p_err_msg:='Error in Insert History';
                END;
end loop;
--
lv_login_approver_count:=null;
end if;


--Get Approver List
            SELECT
                aphis.action_level,
                LISTAGG(aphis.response_user_id, ',') AS approver_user_id,
                LISTAGG(emp.email_address, ',')      AS email_address,
                LISTAGG(emp.person_number, ',')      AS person_number,
                aphis.category
            INTO
                lapplevel,
                lappuserid,
                lappemail,
                lapppernumber,
                lv_category
            FROM
                xxqia_approval_action_history_t aphis,
                employee_detail_v               emp
            WHERE
                    emp.person_id = aphis.response_user_id
                AND aphis.transaction_id = p_primary_id
                AND aphis.action_level = lv_next_level
                AND aphis.object_version_number = nvl(header_ref_cursor.OBJECT_VERSION_NUMBER, 0)
            GROUP BY
                aphis.action_level,aphis.category;

            UPDATE XXQIA_ADMIN_INVOICE_HDR
            SET
                OBJECT_VERSION_NUMBER=nvl(header_ref_cursor.OBJECT_VERSION_NUMBER, 0),
                status = 'Pending',
                approver_id = lapppernumber,
                approver_email = lower(lappemail),
                approver_level = lapplevel,
                approver_number = replace(lapppernumber,'999980','oicft@qia.qa'),
                category = lv_category
            WHERE
                REQUEST_ID = p_primary_id;
            commit;
    p_err_code:='S';
    p_err_msg:='Information Saved Successfully and Submitted for Approval';
else
    p_err_code:='E';
    p_err_msg:='Validation Error';
end if;
exception when OTHERS then 
    p_err_code:='E';
    p_err_msg:=sqlerrm;
end submit_action;


procedure update_action(
	 p_primary_id       IN       VARCHAR2
    ,p_table_name       IN       VARCHAR2
	,p_login_user       IN       VARCHAR2
    ,p_request_type     IN       VARCHAR2
	,p_appr_id			IN       VARCHAR2
    ,p_appr_level       IN       VARCHAR2
	,p_response			IN       VARCHAR2
	,p_ar_status		IN       VARCHAR2
    ,p_seq              OUT      VARCHAR2
    ,p_err_code         OUT      VARCHAR2
    ,p_err_msg          OUT      VARCHAR2
    ,p_flow_status      OUT      VARCHAR2
)IS

cursor submit_cursor
is
select * from 
(
        SELECT
            applv_val  as approver_user_id,
            'Approver' category,
            'INV_APVL' role_name,
            ROWNUM    approver_level
        FROM
            xxqia_admin_invoice_hdr UNPIVOT ( applv_val
                FOR applv
            IN ( 
                 department_approver,
                 approver1,
                 approver2,
                 approver3,
                 approver4,
                 approver5 ) ) unpvt
        WHERE
          REQUEST_ID = p_primary_id
union all 
        SELECT
            to_number(trim(lk.LOOKUP_VALUE_CODE)) AS approver_user_id,
            ah.category,
            ah.role_name,
            ah.approver_level
--            ,ah.enabled_flag,
--            ah.header_id,
--            ah.approval_request_type,
        FROM
            xxqia_approval_hierarchy ah,
            xxfnd_lookup_v           lk
        WHERE
                upper(nvl(ah.role_name, 'XXX')) = upper(nvl(lk.lookup_type_code, 'XXX'))
        --AND lk.LOOKUP_TYPE_CODE='QIA_POINV_FINANCE_REVIEW'
            AND ah.approval_request_type LIKE 'INVOICE'
)
where approver_level = (
SELECT
    MIN(approver_level)
FROM
    (
        SELECT
             applv_val  as  approver_user_id,
            'Approver' category,
            'INV_APVL' role_name,
            ROWNUM     approver_level
        FROM
            xxqia_admin_invoice_hdr UNPIVOT ( applv_val
                FOR applv
            IN ( department_approver,
                 approver1,
                 approver2,
                 approver3,
                 approver4,
                 approver5 ) ) unpvt
        WHERE
            request_id = p_primary_id
        UNION ALL
        SELECT
            to_number(trim(lk.LOOKUP_VALUE_CODE))  AS approver_user_id,
            ah.category,
            ah.role_name,
            ah.approver_level
        FROM
            xxqia_approval_hierarchy ah,
            xxfnd_lookup_v           lk
        WHERE
                upper(nvl(ah.role_name, 'XXX')) = upper(nvl(lk.lookup_type_code, 'XXX'))
            AND ah.approval_request_type LIKE 'INVOICE'
    )
WHERE
    approver_level NOT IN (
        SELECT
            nvl(action_level, 0)
        FROM
            xxqia_approval_action_history_t
        WHERE
            transaction_id = p_primary_id
    )
)
order by approver_level;


cursor header_cursor
is 
SELECT * FROM xxqia_admin_invoice_hdr
where 
REQUEST_ID=p_primary_id;

header_ref_cursor           header_cursor%ROWTYPE;
lv_request_status           VARCHAR2(150) := 'Pending';
lv_status                   VARCHAR2(10) := 'S';
lv_login_approver_count     number;   
lv_seq                      number:=0;
lv_rstatus                  VARCHAR2(150);
lv_app_person_id            number;
lnext_level                 number;

lv_next_level               number;
lapplevel                NUMBER;
lappuserid               VARCHAR2(240);
lappemail                VARCHAR2(240);
lapppernumber            XXQIA_ADMIN_INVOICE_HDR.approver_number%TYPE;
lv_category              XXQIA_ADMIN_INVOICE_HDR.category%TYPE;

begin
--Get lookup Status
        BEGIN
            SELECT
                lookup_value_name
            INTO lv_rstatus
            FROM
                xxfnd_lookup_values flv,
                xxfnd_lookup_types  flt
            WHERE
                    flv.lookup_type_id = flt.lookup_type_id
                AND flt.lookup_type_code = 'XXQIA_STATUS'
                AND lookup_value_code = p_ar_status;

        EXCEPTION
            WHEN OTHERS THEN
                lv_rstatus := p_ar_status;
        END;
--Get lookup Status end
--Get approver Emailid:
          BEGIN
            SELECT
                person_id
            INTO lv_app_person_id
            FROM
--                users_stg
              person_stg
            WHERE
              rownum=1  
            -- Test 
           AND UPPER(person_number) = UPPER(p_login_user);
            --prod
--           AND UPPER(EMAIL_ADDRESS) = UPPER(p_login_user);
        EXCEPTION
            WHEN OTHERS THEN
                lv_app_person_id := -1;
        END;
--next level count        
begin
    select 
    count(*) 
    into lnext_level
    from 
    (
            SELECT
                applv_val  approver_user_id,
                'Approver' category,
                'INV_APVL' role_name,
                ROWNUM    approver_level
            FROM
                xxqia_admin_invoice_hdr UNPIVOT ( applv_val
                    FOR applv
                IN ( 
                     department_approver,
                     approver1,
                     approver2,
                     approver3,
                     approver4,
                     approver5 ) ) unpvt
            WHERE
              REQUEST_ID = p_primary_id
    union all 
            SELECT
                to_number(trim(lk.LOOKUP_VALUE_CODE))  AS approver_user_id,
                ah.category,
                ah.role_name,
                ah.approver_level
    --            ,ah.enabled_flag,
    --            ah.header_id,
    --            ah.approval_request_type,
            FROM
                xxqia_approval_hierarchy ah,
                xxfnd_lookup_v           lk
            WHERE
                    upper(nvl(ah.role_name, 'XXX')) = upper(nvl(lk.lookup_type_code, 'XXX'))
            --AND lk.LOOKUP_TYPE_CODE='QIA_POINV_FINANCE_REVIEW'
                AND ah.approval_request_type LIKE 'INVOICE'
    )
where approver_level = (
SELECT
    MIN(approver_level)
FROM
    (
        SELECT
             applv_val  as  approver_user_id,
            'Approver' category,
            'INV_APVL' role_name,
            ROWNUM     approver_level
        FROM
            xxqia_admin_invoice_hdr UNPIVOT ( applv_val
                FOR applv
            IN ( department_approver,
                 approver1,
                 approver2,
                 approver3,
                 approver4,
                 approver5 ) ) unpvt
        WHERE
            request_id = p_primary_id
        UNION ALL
        SELECT
            to_number(trim(lk.LOOKUP_VALUE_CODE))  AS approver_user_id,
            ah.category,
            ah.role_name,
            ah.approver_level
        FROM
            xxqia_approval_hierarchy ah,
            xxfnd_lookup_v           lk
        WHERE
                upper(nvl(ah.role_name, 'XXX')) = upper(nvl(lk.lookup_type_code, 'XXX'))
            AND ah.approval_request_type LIKE 'INVOICE'
    )
WHERE
    approver_level NOT IN (
        SELECT
            nvl(action_level, 0)
        FROM
            xxqia_approval_action_history_t
        WHERE
            transaction_id = p_primary_id
    )
);
exception when others then 
    lnext_level:=-1;
end;


if(lv_status='S') then 

open header_cursor;
fetch header_cursor into header_ref_cursor;
close header_cursor;

IF trim(upper(p_ar_status)) = 'REJECT' THEN
    UPDATE xxqia_approval_action_history_t
    SET
    action_code =
            CASE
            WHEN ( response_user_id = lv_app_person_id
                AND action_level = p_appr_level ) THEN
                'REJECT'
                ELSE
                'Closed'
                END,
    action_comments =
            CASE
            WHEN ( response_user_id = lv_app_person_id
                AND action_level = p_appr_level ) THEN
                    p_response
                ELSE
                NULL
                END,
    action_date = sysdate
            WHERE
                    transaction_id = p_primary_id
                AND action_code IN ( 'Open', 'Pending' )
                AND object_version_number = header_ref_cursor.OBJECT_VERSION_NUMBER
                AND transaction_source = p_request_type;
            commit;
            --tx table update 
            update XXQIA_ADMIN_INVOICE_HDR
            set STATUS='Rejected'
            where 
            REQUEST_ID=p_primary_id;
            commit;
END IF ;

--FYI

IF trim(upper(p_ar_status)) = 'FYI' THEN
    UPDATE xxqia_approval_action_history_t
    SET
    action_code =
            CASE
            WHEN ( response_user_id = lv_app_person_id
                AND action_level = p_appr_level ) THEN
                'FYI'
                ELSE
                'FYI'
                END,
    action_comments =
            CASE
            WHEN ( response_user_id = lv_app_person_id
                AND action_level = p_appr_level ) THEN
                    'Notification Send'
                ELSE
                    'Notification Send'
                END,
    action_date = sysdate
            WHERE
                    transaction_id = p_primary_id
                AND action_code IN ('Pending')
                AND object_version_number = header_ref_cursor.OBJECT_VERSION_NUMBER
                AND transaction_source = p_request_type;
            commit;

    if(lnext_level=0) then 
        --tx table update 
            update XXQIA_ADMIN_INVOICE_HDR
            set STATUS='Approved',
                approver_id = null,
                approver_email = null,
                approver_level = null,
                approver_number = null,
                category = null
            where 
            REQUEST_ID=p_primary_id;
            commit;
else
--next level history table record insert
begin
submit_action(p_primary_id,p_table_name,p_login_user,p_err_code,p_err_msg);
end;
            p_err_code:='S';
            p_err_msg:='Information Saved Successfully and Submitted for Approval';
    end if;
END IF;

--Approve
IF trim(upper(p_ar_status)) = 'APPROVE' THEN
    UPDATE xxqia_approval_action_history_t
    SET
    action_code =
            CASE
            WHEN ( response_user_id = lv_app_person_id
                AND action_level = p_appr_level ) THEN
                'Approved'
                ELSE
                'Beaten'
                END,
    action_comments =
            CASE
            WHEN ( response_user_id = lv_app_person_id
                AND action_level = p_appr_level ) THEN
                    p_response
                ELSE
                    'Beaten'
                END,
    action_date = sysdate
            WHERE
                    transaction_id = p_primary_id
                AND action_code IN ('Pending')
                AND object_version_number =nvl(header_ref_cursor.OBJECT_VERSION_NUMBER,0)
                AND transaction_source = p_request_type;
            commit;

if(lnext_level=0) then 
        --tx table update 
            update XXQIA_ADMIN_INVOICE_HDR
            set STATUS='Approved',
                approver_id = null,
                approver_email = null,
                approver_level = null,
                approver_number = null,
                category = null
            where 
            REQUEST_ID=p_primary_id;
            commit;
    else
        --next level submit pkg     
        begin
        submit_action(p_primary_id,p_table_name,p_login_user,p_err_code,p_err_msg);
        end;
            p_err_code:='S';
            p_err_msg:='Information Saved Successfully and Submitted for Approval';
    end if;
END IF;

else
    p_err_code:='E';
    p_err_msg:='Validation Error';
end if;
exception when OTHERS then 
    p_err_code:='E';
    p_err_msg:=sqlerrm;
end update_action;



end XXQIA_ADMIN_INV_APPROVAL_PKG;
/
