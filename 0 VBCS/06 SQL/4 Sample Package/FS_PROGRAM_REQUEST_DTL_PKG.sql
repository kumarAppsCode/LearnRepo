CREATE OR REPLACE PACKAGE "FS_PROGRAM_REQUEST_DTL_PKG" IS 
                           PROCEDURE process_data (p_method       IN VARCHAR2
                                                  ,p_primarykey   IN NUMBER
                                                  ,p_data         IN BLOB);
                           PROCEDURE post_data (p_primarykey   IN NUMBER
                                               ,p_data         IN BLOB);
                           PROCEDURE put_data (p_primarykey   IN NUMBER
                                              ,p_data         IN BLOB);
                           PROCEDURE delete_data (p_primarykey   IN NUMBER
                                                 ,p_data         IN BLOB);
                           END FS_PROGRAM_REQUEST_DTL_PKG;
/


CREATE OR REPLACE PACKAGE BODY "FS_PROGRAM_REQUEST_DTL_PKG" IS CURSOR cur_data (
    p_data BLOB
) IS SELECT
         request_id,
         request_number,
         request_date,
         program_id,
         output_type,
         request_data,
         remarks,
         request_status,
         report_file_path,
         error_messge,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login
     FROM
         json_table( P_DATA FORMAT JSON , '$' COLUMNS ( request_id NUMBER PATH '$.request_id',
    request_number VARCHAR2 PATH '$.request_number',
    request_date DATE PATH '$.request_date',
    program_id VARCHAR2 PATH '$.program_id',
    output_type VARCHAR2 PATH '$.output_type',
   request_data CLOB PATH '$.request_data'
,remarks VARCHAR2 PATH '$.remarks'
,request_status VARCHAR2 PATH '$.request_status'
,report_file_path VARCHAR2 PATH '$.report_file_path'
,error_messge VARCHAR2 PATH '$.error_messge'
,creation_date TIMESTAMP PATH '$.creation_date'
,created_by VARCHAR2 PATH '$.created_by'
,last_update_date TIMESTAMP PATH '$.last_update_date'
,last_updated_by VARCHAR2 PATH '$.last_updated_by'
,last_update_login VARCHAR2 PATH '$.last_update_login'
));
rec_data cur_data%ROWTYPE;
l_err_code VARCHAR2 (1);
l_err_msg VARCHAR2 (2000);
l_primarykey NUMBER;

lcobdata fs_program_request_dtl_t.REQUEST_DATA%TYPE;

    PROCEDURE process_data (
        p_method      IN  VARCHAR2,
        p_primarykey  IN  NUMBER,
        p_data        IN  BLOB
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
        p_primarykey  IN  NUMBER,
        p_data        IN  BLOB
    ) IS
        l_seq_id NUMBER := fs_program_id_s.nextval;
    BEGIN
        OPEN cur_data(p_data);
        FETCH cur_data INTO rec_data;
        CLOSE cur_data;

 begin
         SELECT json_query (p_data format json,'$.ldata[*]') clobdata
          INTO lcobdata
          FROM dual;
        end;

        INSERT INTO fs_program_request_dtl_t (
            request_id,
            request_number,
            request_date,
            program_id,
            output_type,
            request_data,
            remarks,
            request_status,
            report_file_path,
            error_messge,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login
        ) VALUES (
            l_seq_id,
            'REQ - ' || l_seq_id,
            sysdate,
            rec_data.program_id,
            rec_data.output_type,
            lcobdata,
            rec_data.remarks,
            rec_data.request_status,
            rec_data.report_file_path,
            rec_data.error_messge,
            rec_data.creation_date,
            rec_data.created_by,
            rec_data.last_update_date,
            rec_data.last_updated_by,
            rec_data.last_update_login
        );

        l_primarykey := l_seq_id;
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
    END post_data;

    PROCEDURE put_data (
        p_primarykey  IN  NUMBER,
        p_data        IN  BLOB
    ) IS
    BEGIN
        OPEN cur_data(p_data);
        FETCH cur_data INTO rec_data;
        CLOSE cur_data;


         BEGIN
         SELECT json_query (p_data format json,'$.ldata[*]') clobdata
          INTO lcobdata
          FROM dual;
      END;

        UPDATE fs_program_request_dtl_t
        SET
            request_number = rec_data.request_number,
            request_date = rec_data.request_date,
            program_id = rec_data.program_id,
            output_type = rec_data.output_type,
            request_data = lcobdata,
            remarks = rec_data.remarks,
            request_status = sysdate,
            report_file_path = rec_data.report_file_path,
            error_messge = rec_data.error_messge,
            creation_date = rec_data.creation_date,
            created_by = rec_data.created_by,
            last_update_date = rec_data.last_update_date,
            last_updated_by = rec_data.last_updated_by,
            last_update_login = rec_data.last_update_login
        WHERE
            request_id = p_primarykey;

        l_primarykey := p_primarykey;
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
    END put_data;
    PROCEDURE delete_data (
        p_primarykey  IN  NUMBER,
        p_data        IN  BLOB
    ) IS
    BEGIN
        OPEN cur_data(p_data);
        FETCH cur_data INTO rec_data;
        CLOSE cur_data;
        DELETE FROM fs_program_request_dtl_t
        WHERE
            request_id = p_primarykey;

        l_primarykey := p_primarykey;
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

end FS_PROGRAM_REQUEST_DTL_PKG;
/
