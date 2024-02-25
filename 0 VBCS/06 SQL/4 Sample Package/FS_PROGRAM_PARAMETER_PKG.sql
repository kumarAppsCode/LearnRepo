CREATE OR REPLACE PACKAGE "FS_PROGRAM_PARAMETER_PKG" IS 
                           PROCEDURE process_data (p_method       IN VARCHAR2
                                                  ,p_primarykey   IN NUMBER
                                                  ,p_data         IN BLOB);
                           PROCEDURE post_data (p_primarykey   IN NUMBER
                                               ,p_data         IN BLOB);
                           PROCEDURE put_data (p_primarykey   IN NUMBER
                                              ,p_data         IN BLOB);
                           PROCEDURE delete_data (p_primarykey   IN NUMBER
                                                 ,p_data         IN BLOB);
                           END FS_PROGRAM_PARAMETER_PKG;
/


CREATE OR REPLACE PACKAGE BODY "FS_PROGRAM_PARAMETER_PKG" IS

    CURSOR cur_data (
        p_data BLOB
    ) IS
    SELECT
        parameter_id,
        program_id,
        parameter_sequence,
        parameter_code,
        parameter_name,
        parameter_data_type,
        parameter_value_type,
        parameter_value,
        mandatory_flag,
        active_flag,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login
    FROM
        JSON_TABLE ( p_data FORMAT JSON, '$'
            COLUMNS (
                parameter_id NUMBER PATH '$.parameter_id',
                program_id NUMBER PATH '$.program_id',
                parameter_sequence VARCHAR2 PATH '$.parameter_sequence',
                parameter_code VARCHAR2 PATH '$.parameter_code',
                parameter_name VARCHAR2 PATH '$.parameter_name',
                parameter_data_type VARCHAR2 PATH '$.parameter_data_type',
                parameter_value_type VARCHAR2 PATH '$.parameter_value_type',
                parameter_value VARCHAR2 PATH '$.parameter_value',
                mandatory_flag VARCHAR2 PATH '$.mandatory_flag',
                active_flag VARCHAR2 PATH '$.active_flag',
                creation_date TIMESTAMP PATH '$.creation_date',
                created_by VARCHAR2 PATH '$.created_by',
                last_update_date TIMESTAMP PATH '$.last_update_date',
                last_updated_by VARCHAR2 PATH '$.last_updated_by',
                last_update_login VARCHAR2 PATH '$.last_update_login'
            )
        );

    rec_data      cur_data%rowtype;
    l_err_code    VARCHAR2(1);
    l_err_msg     VARCHAR2(2000);
    l_primarykey  NUMBER;
--l_attribute_json FS_PROGRAM_PARAMETER_T.attribute_json%TYPE;
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
        INSERT INTO fs_program_parameter_t (
            parameter_id,
            program_id,
            parameter_sequence,
            parameter_code,
            parameter_name,
            parameter_data_type,
            parameter_value_type,
            parameter_value,
            mandatory_flag,
            active_flag,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login
        ) VALUES (
            l_seq_id,
            rec_data.program_id,
            rec_data.parameter_sequence,
            rec_data.parameter_code,
            rec_data.parameter_name,
            rec_data.parameter_data_type,
            rec_data.parameter_value_type,
            rec_data.parameter_value,
            rec_data.mandatory_flag,
            rec_data.active_flag,
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

        UPDATE fs_program_parameter_t
        SET
            program_id = rec_data.program_id,
            parameter_sequence = rec_data.parameter_sequence,
            parameter_code = rec_data.parameter_code,
            parameter_name = rec_data.parameter_name,
            parameter_data_type = rec_data.parameter_data_type,
            parameter_value_type = rec_data.parameter_value_type,
            parameter_value = rec_data.parameter_value,
            mandatory_flag = rec_data.mandatory_flag,
            active_flag = rec_data.active_flag,
            creation_date = rec_data.creation_date,
            created_by = rec_data.created_by,
            last_update_date = rec_data.last_update_date,
            last_updated_by = rec_data.last_updated_by,
            last_update_login = rec_data.last_update_login
        WHERE
            parameter_id =  p_primarykey;

        l_primarykey :=  p_primarykey;
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
        DELETE FROM fs_program_parameter_t
        WHERE
            parameter_id =  p_primarykey;

        l_primarykey :=  p_primarykey;
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

END fs_program_parameter_pkg;
/
