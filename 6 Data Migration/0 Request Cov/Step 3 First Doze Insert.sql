
set SERVEROUTPUT ON;
DECLARE
    CURSOR getdata IS
    SELECT 
    NAME,
    EMPLOYEE_NUMBER,
    CREATION_DATE,
    REGION_CODE,
    PERSON_ID,
    json_object(
    'vaccination_type' value 'First Dose',
    'vaccination_status' value FIRST_DOZE,
    'vaccination_date' value to_char(FIRST_DOZE_DATE, 'RRRR-MM-RR'),
    'vaccine_region' value REGION,
    'vaccination_reason' value NVL(REASON, '-')
    ) as ldata
    FROM tttttt
    where 
    first_doze_update is null
    and PERSON_ID is not null
    and REGION_CODE is not null
    and FIRST_DOZE_UPDATE is null
--  and EMPLOYEE_NUMBER='4008'
    ;

lcount number:=0;
lseq number:=null;

BEGIN FOR c0 IN getdata 
LOOP 
lseq:=FS_TRANSACTION_ID.nextval;
INSERT INTO aaa (
    request_id,
    object_version_num,
    request_number,
    request_type_id,
    REQUEST_TYPE,
    REQUESTER_ID,
    PERSON_ID,
	REQUEST_DATE,
    REQUEST_DATA,
    description,
    request_status,
    integration_status,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
    )VALUES (
    lseq,
    0,
    'COVDM00'||lseq,
    100518,
    'COVID_VACCINATION_REQUEST',
    c0.PERSON_ID,
    c0.PERSON_ID,
    c0.CREATION_DATE,
	to_clob(c0.ldata),
    'Data Migration',
    'Draft', --Approved
    'Y',
    c0.EMPLOYEE_NUMBER,
    systimestamp,
    c0.EMPLOYEE_NUMBER,
    systimestamp,
    c0.EMPLOYEE_NUMBER
    );
commit;

update tttttt
set FIRST_DOZE_UPDATE='Y'
where 
trim(EMPLOYEE_NUMBER)=trim(c0.EMPLOYEE_NUMBER);
commit;
lcount:=lcount+1;
--dbms_output.put_line('lseq:=>'||lseq);
lseq:=null;
end loop;
dbms_output.put_line('Total No of Record:=>'||lcount);
END;