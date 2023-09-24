CREATE OR REPLACE PACKAGE FS_CUSTOM_REPORT_PKG IS 
                           PROCEDURE process_data (p_method       IN VARCHAR2
                                                  ,p_primarykey   IN NUMBER
                                                  ,p_data         IN BLOB);
                           PROCEDURE post_data (p_primarykey   IN NUMBER
                                               ,p_data         IN BLOB);
                           PROCEDURE put_data (p_primarykey   IN NUMBER
                                              ,p_data         IN BLOB);
                           PROCEDURE delete_data (p_primarykey   IN NUMBER
                                                 ,p_data         IN BLOB);
                           END FS_CUSTOM_REPORT_PKG;
/


CREATE OR REPLACE PACKAGE BODY fs_custom_report_pkg IS

    CURSOR cur_data (
        p_data BLOB
    ) IS
    SELECT
        report_id,
        report_code,
        report_name,
        report_path,
        rtf_file_name,
        service_base_path,
        service_path,
        file_name,
        file_type,
        description,
        request_data,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
    FROM
        JSON_TABLE ( p_data FORMAT JSON, '$'
            COLUMNS (
                report_id NUMBER PATH '$.report_id',
                report_code VARCHAR2 PATH '$.report_code',
                report_name VARCHAR2 PATH '$.report_name',
                report_path VARCHAR2 PATH '$.report_path',
                rtf_file_name VARCHAR2 PATH '$.rtf_file_name',
                service_base_path VARCHAR2 PATH '$.service_base_path',
                service_path VARCHAR2 PATH '$.service_path',
                file_name VARCHAR2 PATH '$.file_name',
                file_type VARCHAR2 PATH '$.file_type',
                description VARCHAR2 PATH '$.description',
                request_data CLOB PATH '$.request_data',
                created_by VARCHAR2 PATH '$.created_by',
                creation_date TIMESTAMP PATH '$.creation_date',
                last_updated_by VARCHAR2 PATH '$.last_updated_by',
                last_update_date TIMESTAMP PATH '$.last_update_date',
                last_update_login VARCHAR2 PATH '$.last_update_login'
            )
        );

    rec_data     cur_data%rowtype;
    l_err_code   VARCHAR2(1);
    l_err_msg    VARCHAR2(2000);
    l_primarykey NUMBER;
--l_attribute_json FS_CUSTOM_REPORT.attribute_json%TYPE;
      lclobdata FS_CUSTOM_REPORT.REQUEST_DATA%TYPE;
    PROCEDURE process_data (
        p_method     IN VARCHAR2,
        p_primarykey IN NUMBER,
        p_data       IN BLOB
    ) IS
    BEGIN
        IF p_method = 'POST' THEN
            post_data(p_primarykey, p_data);
        ELSIF p_method = 'PUT' THEN
            put_data(p_primarykey, p_data);
        ELSIF p_method = 'DELETE' THEN
            delete_data(p_primarykey, p_data);
        END IF;
    END process_data;

    PROCEDURE post_data (
        p_primarykey IN NUMBER,
        p_data       IN BLOB
    ) IS
        l_seq_id NUMBER := FS_CUSTOM_REPORT_S.nextval;
        lcount number;
        lcount1 number;
    BEGIN
        OPEN cur_data(p_data);
        FETCH cur_data INTO rec_data;
        CLOSE cur_data;
        
BEGIN
        SELECT json_query (p_data format json,'$.ldata[*]') clobdata
        INTO lclobdata
        FROM dual;
end;
 begin
        SELECT COUNT(*) into lcount
        FROM fs_custom_report
        WHERE 
--        report_id=rec_data.report_id AND
         rtf_file_name=rec_data.rtf_file_name;
        exception when others then 
            lcount:=0;        
        end;
  if(lcount=0) then        
        INSERT INTO fs_custom_report (
            report_id,
            report_code,
            report_name,
            report_path,
            rtf_file_name,
            service_base_path,
            service_path,
            file_name,
            file_type,
            description,
            request_data,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login
        ) VALUES (
            l_seq_id,
            rec_data.report_code,
            rec_data.report_name,
            rec_data.report_path,
            rec_data.rtf_file_name,
            rec_data.service_base_path,
            rec_data.service_path,
            rec_data.file_name,
            rec_data.file_type,
            rec_data.description,
            lclobdata,
            rec_data.created_by,
            rec_data.creation_date,
            rec_data.last_updated_by,
            rec_data.last_update_date,
            rec_data.last_update_login
        );

        l_primarykey := l_seq_id;
        COMMIT;
        l_err_code := 'S';
        l_err_msg := 'Information Saved Successfully';
          else
        l_err_code := 'E';
        l_err_msg := 'RTF File Name already exist';
            end if ;
        apex_json.open_object;
        apex_json.write('p_err_code', l_err_code);
        apex_json.write('p_err_msg', l_err_msg);
        apex_json.write('p_primarykey', l_primarykey);
        apex_json.close_object;
    EXCEPTION
        WHEN OTHERS THEN
            l_err_code := 'E';
            l_err_msg := 'API Error - ' || sqlerrm;
            dbms_output.put_line('Error > '
                                 || sqlcode
                                 || sqlerrm);
            apex_json.open_object;
            apex_json.write('p_err_code', l_err_code);
            apex_json.write('p_err_msg', l_err_msg);
            apex_json.write('p_primarykey', l_primarykey);
            apex_json.close_object;
    END post_data;

    PROCEDURE put_data (
        p_primarykey IN NUMBER,
        p_data       IN BLOB
    ) IS
    lcount1 number;
    BEGIN
        OPEN cur_data(p_data);
        FETCH cur_data INTO rec_data;
        CLOSE cur_data;
/*BEGIN
                            SELECT json_query (p_data format json,'$.attribute_json[*]') clobdata INTO l_attribute_json FROM DUAL;
                       END;*/
                       
BEGIN
        SELECT json_query (p_data format json,'$.ldata[*]') clobdata
        INTO lclobdata
        FROM dual;
end;
 begin
        SELECT COUNT(*) into lcount1
        FROM fs_custom_report
        WHERE 
--        report_id=rec_data.report_id AND
         rtf_file_name=rec_data.rtf_file_name;
        exception when others then 
            lcount1:=0;        
        end;
 if(lcount1=0) then      
        UPDATE fs_custom_report
        SET
            report_code = rec_data.report_code,
            report_name = rec_data.report_name,
            report_path = rec_data.report_path,
            rtf_file_name = rec_data.rtf_file_name,
            service_base_path = rec_data.service_base_path,
            service_path = rec_data.service_path,
            file_name = rec_data.file_name,
            file_type = rec_data.file_type,
            description = rec_data.description,
            request_data = lclobdata,
            created_by = rec_data.created_by,
            creation_date = rec_data.creation_date,
            last_updated_by = rec_data.last_updated_by,
            last_update_date = rec_data.last_update_date,
            last_update_login = rec_data.last_update_login
        WHERE
            report_id = rec_data.report_id;

        l_primarykey := rec_data.report_id;
        COMMIT;
        l_err_code := 'S';
        l_err_msg := 'Information Saved Successfully';
            else
        l_err_code := 'E';
        l_err_msg := 'RTF File Name already exist';
            end if ;
        apex_json.open_object;
        apex_json.write('p_err_code', l_err_code);
        apex_json.write('p_err_msg', l_err_msg);
        apex_json.write('p_primarykey', l_primarykey);
        apex_json.close_object;
    EXCEPTION
        WHEN OTHERS THEN
            l_err_code := 'E';
            l_err_msg := 'API Error - ' || sqlerrm;
            dbms_output.put_line('Error > '
                                 || sqlcode
                                 || sqlerrm);
            apex_json.open_object;
            apex_json.write('p_err_code', l_err_code);
            apex_json.write('p_err_msg', l_err_msg);
            apex_json.write('p_primarykey', l_primarykey);
            apex_json.close_object;
    END put_data;

    PROCEDURE delete_data (
        p_primarykey IN NUMBER,
        p_data       IN BLOB
    ) IS
    BEGIN
        OPEN cur_data(p_data);
        FETCH cur_data INTO rec_data;
        CLOSE cur_data;
        DELETE FROM fs_custom_report
        WHERE
            report_id = p_primarykey;

        l_primarykey := rec_data.report_id;
        COMMIT;
        l_err_code := 'S';
        l_err_msg := 'Information Saved Successfully';
        apex_json.open_object;
        apex_json.write('p_err_code', l_err_code);
        apex_json.write('p_err_msg', l_err_msg);
        apex_json.write('p_primarykey', l_primarykey);
        apex_json.close_object;
    EXCEPTION
        WHEN OTHERS THEN
            l_err_code := 'E';
            l_err_msg := 'API Error - ' || sqlerrm;
            dbms_output.put_line('Error > '
                                 || sqlcode
                                 || sqlerrm);
            apex_json.open_object;
            apex_json.write('p_err_code', l_err_code);
            apex_json.write('p_err_msg', l_err_msg);
            apex_json.write('p_primarykey', l_primarykey);
            apex_json.close_object;
    END delete_data;

END fs_custom_report_pkg;
/
