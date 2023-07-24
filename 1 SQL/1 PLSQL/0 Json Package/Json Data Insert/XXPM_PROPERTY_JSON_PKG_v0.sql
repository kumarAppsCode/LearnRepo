--------------------------------------------------------
--  File created - Wednesday-September-08-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure XXPM_PROPERTY_JSON_PKG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "XXREF_WK1"."XXPM_PROPERTY_JSON_PKG" (propertydtl IN VARCHAR2, pout out VARCHAR2) 
IS

  l_json_text VARCHAR2(32767):='';
  l_json_count     PLS_INTEGER;
  l_members   WWV_FLOW_T_VARCHAR2;
  l_paths     APEX_T_VARCHAR2;
  l_exists    BOOLEAN;
  l_hdr_id  number;
  l_json_child_count     PLS_INTEGER;
  l_hdr_count number;
  l_err_msg varchar2(32767);
  l_line_count number;
BEGIN

  l_json_text:=propertydtl;

  APEX_JSON.parse(l_json_text);

  l_json_count := APEX_JSON.get_count(p_path => 'l_data');
--  DBMS_OUTPUT.put_line('Total JSON Count: ' || l_json_count);
--  DBMS_OUTPUT.put_line('LOOP ALL JSON');
  FOR i IN 1 .. l_json_count LOOP
--    DBMS_OUTPUT.put_line('LINE LOOP : ' || i); 
--    DBMS_OUTPUT.put_line('PROPERTY_ID:' ||APEX_JSON.get_varchar2(p_path => 'l_data[%d].PROPERTY_ID', p0 => i)); 
    IF(APEX_JSON.get_varchar2(p_path => 'l_data[%d].PROPERTY_ID', p0 => i) IS NULL) THEN
    DBMS_OUTPUT.put_line('IS NULL');
    --HEADER INSERT
        l_hdr_id:=XXPM_PROPERTY_ID_S.NEXTVAL;
        INSERT INTO xxpm_property_master (
        property_id,
        property_name,
        property_name_tl,
        property_number,
        property_shortcode,
        func_id,
        org_id,
        project_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
        ) VALUES (
            l_hdr_id,
            APEX_JSON.get_varchar2(p_path => 'l_data[%d].PROPERTY_NAME', p0 => i),
            APEX_JSON.get_varchar2(p_path => 'l_data[%d].PROPERTY_NAME_TL', p0 => i),
            APEX_JSON.get_varchar2(p_path => 'l_data[%d].PROPERTY_NUMBER', p0 => i),
            APEX_JSON.get_varchar2(p_path => 'l_data[%d].PROPERTY_SHORTCODE', p0 => i),
            1,
            300000002526050,
            300000002552905,
            'API',
            SYSDATE,
            'API',
            SYSDATE,
            'API'
        );
        COMMIT;
        --LOOP CHID JSON
          l_json_child_count := APEX_JSON.get_count(p_path => 'l_data[%d].AREALINE', p0 => i);
--          DBMS_OUTPUT.put_line('Total CHILD JSON Count: ' || l_json_child_count);
           FOR j IN 1 .. l_json_child_count LOOP
--            DBMS_OUTPUT.put_line('Child loop' || j); 
--              DBMS_OUTPUT.put_line('***Header is new record so calling insert statement and no update');
--              DBMS_OUTPUT.put_line('AREA_ID: ' ||
--              APEX_JSON.get_varchar2(p_path => 'l_data[%d].AREALINE[%d].AREA_ID', p0 => i, p1 => j)); 
               INSERT INTO XXPM_PROPERTY_AREA (
                AREA_ID,
                PROPERTY_ID,
                BUILD_ID,
                UNIT_ID,
                AREA,
                UOM,
                VALUE,
                DESCRIPTION,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN
            ) VALUES (
                XXPM_AREA_ID_S.nextval,
                l_hdr_id,
                null,
                null,
                APEX_JSON.get_varchar2(p_path => 'l_data[%d].AREALINE[%d].AREA',  p0 => i, p1 => j),
                APEX_JSON.get_varchar2(p_path => 'l_data[%d].AREALINE[%d].UOM',  p0 => i, p1 => j),
                APEX_JSON.get_varchar2(p_path => 'l_data[%d].AREALINE[%d].VALUE',  p0 => i, p1 => j),
                'Sample Description',
                'API',
                sysdate,
                'API',
                sysdate,
                'API'
            ); 
           END LOOP;
        --NEW RECORD INSERT COMPELTED                      
    ELSE
    --UPDATE QUERY
        l_hdr_count:=null;
        BEGIN
            SELECT COUNT(*) INTO l_hdr_count
            FROM XXPM_PROPERTY_MASTER 
            WHERE PROPERTY_ID=NVL(APEX_JSON.get_varchar2(p_path => 'l_data[%d].PROPERTY_ID', p0 => i),0);
        Exception when others then 
        l_hdr_count:=null;
        END;
        --
        IF(l_hdr_count=1)THEN 
        --HDR UPDATE   
            UPDATE XXPM_PROPERTY_MASTER
            SET PROPERTY_NAME=APEX_JSON.get_varchar2(p_path => 'l_data[%d].PROPERTY_NAME', p0 => i)
            ,PROPERTY_NAME_TL=APEX_JSON.get_varchar2(p_path => 'l_data[%d].PROPERTY_NAME_TL', p0 => i)
            ,PROPERTY_NUMBER=APEX_JSON.get_varchar2(p_path => 'l_data[%d].PROPERTY_NUMBER', p0 => i)
            ,PROPERTY_SHORTCODE=APEX_JSON.get_varchar2(p_path => 'l_data[%d].PROPERTY_SHORTCODE', p0 => i)
            ,NO_OF_UNITS=APEX_JSON.get_varchar2(p_path => 'l_data[%d].NO_OF_UNITS', p0 => i)
            WHERE
             PROPERTY_ID=APEX_JSON.get_varchar2(p_path => 'l_data[%d].PROPERTY_ID', p0 => i);
            COMMIT;
            --CHILD TABLE UPDATE/INSERT
            l_json_child_count := APEX_JSON.get_count(p_path => 'l_data[%d].AREALINE', p0 => i);
            FOR j IN 1 .. l_json_child_count LOOP
--            DBMS_OUTPUT.put_line('Child loop' || j); 
--              DBMS_OUTPUT.put_line('***Header is new record so calling insert statement and no update');
--              DBMS_OUTPUT.put_line('AREA_ID: ' ||
--              APEX_JSON.get_varchar2(p_path => 'l_data[%d].AREALINE[%d].AREA_ID', p0 => i, p1 => j)); 
                    IF(APEX_JSON.get_varchar2(p_path => 'l_data[%d].AREALINE[%d].AREA_ID', p0 => i, p1 => j) IS NOT NULL) THEN 
                        l_line_count:=NULL;
                        BEGIN                    
                            SELECT NVL(COUNT(*),0) INTO l_line_count
                            FROM XXPM_PROPERTY_AREA 
                            WHERE AREA_ID=NVL(APEX_JSON.get_varchar2(p_path => 'l_data[%d].AREALINE[%d].AREA_ID', p0 => i, p1 => j),0);
                        exception when others then 
                        l_line_count:=null;
                        END;
--                        DBMS_OUTPUT.put_line('COUNT==>'||l_line_count);                    
                        IF(l_line_count=1) THEN
                            UPDATE XXPM_PROPERTY_AREA
                            SET 
                            AREA=APEX_JSON.get_varchar2(p_path => 'l_data[%d].AREALINE[%d].AREA',  p0 => i, p1 => j),
                            UOM=APEX_JSON.get_varchar2(p_path => 'l_data[%d].AREALINE[%d].UOM',  p0 => i, p1 => j),
                            VALUE=APEX_JSON.get_varchar2(p_path => 'l_data[%d].AREALINE[%d].VALUE',  p0 => i, p1 => j)
                            WHERE
                            AREA_ID=APEX_JSON.get_varchar2(p_path => 'l_data[%d].AREALINE[%d].AREA',  p0 => i, p1 => j);
                            COMMIT;                        
                        ELSE 
                            NULL;
                            --RECORD ERROR
                            DBMS_OUTPUT.put_line('**==>');                    
                            l_err_msg:=l_err_msg||','||APEX_JSON.get_varchar2(p_path => 'l_data[%d].AREALINE[%d].AREA_ID', p0 => i, p1 => j)||'NOT FOUND';
                        END IF;
                    ELSE 
--                    DBMS_OUTPUT.put_line('INSERT==>');                    
                        INSERT INTO XXPM_PROPERTY_AREA (
                            AREA_ID,
                            PROPERTY_ID,
                            BUILD_ID,
                            UNIT_ID,
                            AREA,
                            UOM,
                            VALUE,
                            DESCRIPTION,
                            CREATED_BY,
                            CREATION_DATE,
                            LAST_UPDATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATE_LOGIN
                        ) VALUES (
                            XXPM_AREA_ID_S.nextval,
                            APEX_JSON.get_varchar2(p_path => 'l_data[%d].PROPERTY_ID', p0 => i),
                            null,
                            null,
                            APEX_JSON.get_varchar2(p_path => 'l_data[%d].AREALINE[%d].AREA',  p0 => i, p1 => j),
                            APEX_JSON.get_varchar2(p_path => 'l_data[%d].AREALINE[%d].UOM',  p0 => i, p1 => j),
                            APEX_JSON.get_varchar2(p_path => 'l_data[%d].AREALINE[%d].VALUE',  p0 => i, p1 => j),
                            'Sample Description',
                            'API',
                            sysdate,
                            'API',
                            sysdate,
                            'API'
                        );                     
                    END IF;
           END LOOP;    
        ELSE
        l_err_msg:=l_err_msg||','||APEX_JSON.get_varchar2(p_path => 'l_data[%d].PROPERTY_ID', p0 => i)||'NOT FOUND';
        END IF;
    DBMS_OUTPUT.put_line('IS NOT NULL');
    END IF;
  END LOOP;  
  DBMS_OUTPUT.put_line('----------------------------------------'); 
pout:='Y';
END XXPM_PROPERTY_JSON_PKG;

/
