
set SERVEROUTPUT ON;
DECLARE
    CURSOR getdata IS
    SELECT * FROM tttttt
    WHERE
    REGION_CODE is null;
        
l_region_code varchar2(240);
l_count number:=0;

BEGIN 
FOR c0 IN getdata 
LOOP 
    l_region_code:=null;
    begin
        SELECT 
        LOOKUP_VALUE_NAME 
        into 
        l_region_code
        FROM Ttete
        where
        1=1
        and rownum=1
        and LOOKUP_TYPE_NAME='VACCINE_REGION'
        and trim(upper(LOOKUP_VALUE_NAME_DISP)) like trim(upper(c0.REGION));
    exception when others then 
       l_region_code:=null;
    end;

    if(l_region_code is not null) then 
        update tttttt
        set REGION_CODE=l_region_code
        where 
        trim(EMPLOYEE_NUMBER)=trim(c0.EMPLOYEE_NUMBER);
        commit;
        l_count:=l_count+1;
    end if;

end loop;
    dbms_output.put_line('l_count:==>'||l_count);
END;