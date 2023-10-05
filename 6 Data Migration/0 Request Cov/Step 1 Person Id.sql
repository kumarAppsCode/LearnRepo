set SERVEROUTPUT ON;
DECLARE
    CURSOR getdata IS
        SELECT * FROM taaa
    WHERE
        PERSON_ID is null;
        
l_person_id number;
l_count number:=0;
BEGIN FOR c0 IN getdata 
LOOP 
    l_person_id:=null;
    begin
        SELECT 
        PERSON_ID into l_person_id
        FROM 
        fs_person_stg_t 
        where 
        rownum=1
        and trim(PERSON_NUMBER)=trim(c0.EMPLOYEE_NUMBER);
    exception when others then 
       l_person_id:=null;
    end;

    update taaa
    set PERSON_ID=l_person_id
    where 
    trim(EMPLOYEE_NUMBER)=trim(c0.EMPLOYEE_NUMBER);
    commit;
l_count:=l_count+1;
end loop;

    dbms_output.put_line('l_count:==>'||l_count);
END;