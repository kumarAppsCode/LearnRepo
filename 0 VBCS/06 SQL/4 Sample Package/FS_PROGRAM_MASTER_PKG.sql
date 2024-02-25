CREATE OR REPLACE PACKAGE "FS_PROGRAM_MASTER_PKG" IS 
                           PROCEDURE process_data (p_method       IN VARCHAR2
                                                  ,p_primarykey   IN NUMBER
                                                  ,p_data         IN BLOB);
                           PROCEDURE post_data (p_primarykey   IN NUMBER
                                               ,p_data         IN BLOB);
                           PROCEDURE put_data (p_primarykey   IN NUMBER
                                              ,p_data         IN BLOB);
                           PROCEDURE delete_data (p_primarykey   IN NUMBER
                                                 ,p_data         IN BLOB);
                           END FS_PROGRAM_MASTER_PKG;
/


CREATE OR REPLACE PACKAGE BODY "FS_PROGRAM_MASTER_PKG" IS

    CURSOR cur_data (
        p_data BLOB
    ) IS
    SELECT
        program_id,
        program_code,
        program_name,
        description,
        source_application,
        program_type,
        rtf_path,
        rtf_name,
        db_function_name,
        output_type,
        active_flag,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        program_download
    FROM
        JSON_TABLE ( p_data FORMAT JSON, '$'
            COLUMNS (
                program_id NUMBER PATH '$.program_id',
                program_code VARCHAR2 PATH '$.program_code',
                program_name VARCHAR2 PATH '$.program_name',
                description VARCHAR2 PATH '$.description',
                source_application VARCHAR2 PATH '$.source_application',
                program_type VARCHAR2 PATH '$.program_type',
                rtf_path VARCHAR2 PATH '$.rtf_path',
                rtf_name VARCHAR2 PATH '$.rtf_name',
                db_function_name VARCHAR2 PATH '$.db_function_name',
                output_type VARCHAR2 PATH '$.output_type',
                active_flag VARCHAR2 PATH '$.active_flag',
                creation_date TIMESTAMP PATH '$.creation_date',
                created_by VARCHAR2 PATH '$.created_by',
                last_update_date TIMESTAMP PATH '$.last_update_date',
                last_updated_by VARCHAR2 PATH '$.last_updated_by',
                last_update_login VARCHAR2 PATH '$.last_update_login',
                program_download VARCHAR2 PATH '$.program_download'
            )
        );

    rec_data      cur_data%rowtype;
    l_err_code    VARCHAR2(1);
    l_err_msg     VARCHAR2(2000);
    l_primarykey  NUMBER;
--l_attribute_json FS_PROGRAM_MASTER_T.attribute_json%TYPE;
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
        l_seq_id NUMBER := FS_PROGRAM_ID_S.nextval;
    BEGIN
        OPEN cur_data(p_data);
        FETCH cur_data INTO rec_data;
        CLOSE cur_data;
        INSERT INTO fs_program_master_t (
            program_id,
            program_code,
            program_name,
            description,
            source_application,
            program_type,
            rtf_path,
            rtf_name,
            db_function_name,
            output_type,
            active_flag,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_download
        ) VALUES (
            l_seq_id,
            rec_data.program_code,
            rec_data.program_name,
            rec_data.description,
            rec_data.source_application,
            rec_data.program_type,
            rec_data.rtf_path,
            rec_data.rtf_name,
            rec_data.db_function_name,
            rec_data.output_type,
            rec_data.active_flag,
            rec_data.creation_date,
            rec_data.created_by,
            rec_data.last_update_date,
            rec_data.last_updated_by,
            rec_data.last_update_login,
            rec_data.program_download
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
        UPDATE fs_program_master_t
        SET
            program_code = rec_data.program_code,
            program_name = rec_data.program_name,
            description = rec_data.description,
            source_application = rec_data.source_application,
            program_type = rec_data.program_type,
            rtf_path = rec_data.rtf_path,
            rtf_name = rec_data.rtf_name,
            db_function_name = rec_data.db_function_name,
            output_type = rec_data.output_type,
            active_flag = rec_data.active_flag,
            creation_date = rec_data.creation_date,
            created_by = rec_data.created_by,
            last_update_date = rec_data.last_update_date,
            last_updated_by = rec_data.last_updated_by,
            last_update_login = rec_data.last_update_login,
            program_download = rec_data.program_download
        WHERE
            program_id = p_primarykey;

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
        DELETE FROM fs_program_master_t
        WHERE
            program_id = p_primarykey;

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

END fs_program_master_pkg;
/
