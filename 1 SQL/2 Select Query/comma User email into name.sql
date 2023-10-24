create or replace function xxnws_get_approver_names(p_transaction_id in number)
return varchar2 is
lc_emp_names varchar2(1500);
cursor q1_cur
is
SELECT approver_user_id
FROM fs_approval_action_t
WHERE 
transaction_id=p_transaction_id;

cursor emp_cur (p_appr_user_id in varchar2)
is
select person_id,person_number||'-'||first_name||' '||last_name employee_name from fs_person_stg_t
where sysdate between effective_start_date and effective_end_Date
and (
   person_id = REGEXP_SUBSTR(p_appr_user_id,'[^,]+',1,1)
or person_id = REGEXP_SUBSTR(p_appr_user_id,'[^,]+',1,2)
or person_id = REGEXP_SUBSTR(p_appr_user_id,'[^,]+',1,3)
or person_id = REGEXP_SUBSTR(p_appr_user_id,'[^,]+',1,4)
or person_id = REGEXP_SUBSTR(p_appr_user_id,'[^,]+',1,5)
or person_id = REGEXP_SUBSTR(p_appr_user_id,'[^,]+',1,6)
or person_id = REGEXP_SUBSTR(p_appr_user_id,'[^,]+',1,8)
or person_id = REGEXP_SUBSTR(p_appr_user_id,'[^,]+',1,9)
or person_id = REGEXP_SUBSTR(p_appr_user_id,'[^,]+',1,10)
or person_id = REGEXP_SUBSTR(p_appr_user_id,'[^,]+',1,11)
);
begin
for q1_rec in q1_cur
loop
for emp_rec in emp_cur(q1_rec.approver_user_id)
loop
if emp_rec.employee_name is not null
then
if lc_emp_names is not null 
then
lc_emp_names:=lc_emp_names||','||emp_rec.employee_name;
else
lc_emp_names:=emp_rec.employee_name;
end if;
else
exit;
end if;
end loop;
end loop;
return lc_emp_names;
end;
