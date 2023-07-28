CREATE OR REPLACE PACKAGE xxnss_pkg AS
    PROCEDURE xxnss_import_file (
        p_data   IN BLOB,
        x_status OUT VARCHAR2,
        x_batch_id out number
    );
    
    PROCEDURE xxnss_staging_import_file (
        p_data   IN BLOB,
        x_status OUT VARCHAR2,
        x_batch_id out number
    );
    
     PROCEDURE xxnss_validate_data (
       p_batch_no IN NUMBER,
        p_status OUT VARCHAR2
    );
    
    PROCEDURE xxnss_school_validate_nss_data (
        p_batch_no IN NUMBER,
        p_status   OUT VARCHAR2
    );
    PROCEDURE xxnss_brand_validate_nss_data (
        p_batch_no IN NUMBER,
        p_status   OUT VARCHAR2
    );
    PROCEDURE xxnss_board_validate_nss_data (
        p_batch_no IN NUMBER,
        p_status   OUT VARCHAR2
    );
    PROCEDURE xxnss_grade_validate_nss_data (
        p_batch_no IN NUMBER,
        p_status   OUT VARCHAR2
    );
    PROCEDURE xxnss_category_validate_data  (
        p_batch_no IN NUMBER,
        p_status   OUT VARCHAR2
    );
    PROCEDURE xxnss_terms_phase_validate_nss_data (
        p_batch_no IN NUMBER,
        p_status   OUT VARCHAR2
    );

    PROCEDURE xxnss_update_nss_details_batch_proc (
        p_data   IN BLOB,
        x_status OUT VARCHAR2
    );

    PROCEDURE xxnss_initiate_approval_flow (
        p_nss_id         IN NUMBER,
        p_curr_seq       IN NUMBER,
        p_approver_email IN VARCHAR2,
        p_status out VARCHAR2
    );

    PROCEDURE xxnss_update_each_respones (
        p_nss_id            IN NUMBER,
        p_curr_seq          IN NUMBER,
        p_approver_response IN VARCHAR2,
        p_status out VARCHAR2
    );

    PROCEDURE xxnss_update_final_respones (
        p_nss_id            IN NUMBER,
        p_curr_seq          IN NUMBER,
        p_approver_response IN VARCHAR2,
        p_status out VARCHAR2
    );

END xxnss_pkg;
/


CREATE OR REPLACE PACKAGE BODY xxnss_pkg AS

    PROCEDURE xxnss_import_file (
        p_data     IN BLOB,
        x_status   OUT VARCHAR2,
        x_batch_id OUT NUMBER
    ) IS

        TYPE t_nss_details_tab IS
            TABLE OF xxnss_details%rowtype;
        l_nss_details_tab   t_nss_details_tab := t_nss_details_tab();
        l_top_obj           json_object_t;
        l_nss_arr           json_array_t;
        l_nss_obj           json_object_t;
        l_file_name         VARCHAR2(500);
        l_file_type         VARCHAR2(300);
        l_created_by        VARCHAR2(500);
        l_last_updated_by   VARCHAR2(500);
        l_approvals_info_id NUMBER;
        l_version           NUMBER;
        l_staging_outcome   VARCHAR2(1);
        l_ret_batch_no      NUMBER;
        l_validation_status VARCHAR2(10);
    BEGIN
        l_ret_batch_no := 0;
        l_staging_outcome := 'N';
        xxnss_pkg.xxnss_staging_import_file(
                                           p_data,
                                           l_staging_outcome,
                                           l_ret_batch_no
        );
        dbms_output.put_line('stage-->' || l_staging_outcome);
        IF l_staging_outcome = 'Y' THEN
            xxnss_pkg.xxnss_validate_data(
                                         l_ret_batch_no,
                                         l_validation_status
            );
            IF l_validation_status = 'SUCCESS' THEN
                l_top_obj := json_object_t(p_data);
                l_file_name := l_top_obj.get_string('p_file_name');
                l_version := l_top_obj.get_string('p_version');
                l_file_type := l_top_obj.get_string('p_file_mime_type');
                l_created_by := l_top_obj.get_string('p_created_by');
                l_last_updated_by := l_top_obj.get_string('p_last_updated_by');
                l_approvals_info_id := xxnss_approvals_info_s.nextval;
                INSERT INTO xxnss_approvals_info (
                    approvals_info_id,
                    ay,
                    school,
                    category_info,
                    file_name,
                    file_mime_type,
                    created_date,
                    created_by,
                    last_updated_date,
                    last_updated_by,
                    approval_status,
                    phase_info
                ) VALUES (
                    l_approvals_info_id,
                    l_nss_obj.get_string(
                        'ay'
                    ),
                    l_nss_obj.get_string(
                        'school'
                    ),
                    l_nss_obj.get_string(
                        'category_info'
                    ),
                    l_file_name,
                    l_file_type,
                    sysdate,
                    l_created_by,
                    sysdate,
                    l_last_updated_by,
                    'Pending for Approval',
                    l_nss_obj.get_string(
                        'phase_info'
                    )
                );

                l_nss_arr := l_top_obj.get_array('nss_items');
                FOR i IN 0..l_nss_arr.get_size - 1 LOOP
                    l_nss_obj := TREAT(l_nss_arr.get(i) AS json_object_t);
                    l_nss_details_tab.extend;
                    l_nss_details_tab(l_nss_details_tab.last).s_no := l_nss_obj.get_string('SNo');
                    l_nss_details_tab(l_nss_details_tab.last).ay := l_nss_obj.get_string('AY');
                    l_nss_details_tab(l_nss_details_tab.last).school := l_nss_obj.get_string('School');
                    l_nss_details_tab(l_nss_details_tab.last).category_info := l_nss_obj.get_string('Category');
                    l_nss_details_tab(l_nss_details_tab.last).term_phase := l_nss_obj.get_string('Term/Phase');
                    l_nss_details_tab(l_nss_details_tab.last).brand_info := l_nss_obj.get_string('Brand');
                    l_nss_details_tab(l_nss_details_tab.last).board_info := l_nss_obj.get_string('Board');
                    l_nss_details_tab(l_nss_details_tab.last).grade := l_nss_obj.get_string('Grade');
                    l_nss_details_tab(l_nss_details_tab.last).sku_details := l_nss_obj.get_string('SKU');
                    l_nss_details_tab(l_nss_details_tab.last).student_count := l_nss_obj.get_string('Student Count');
                    l_nss_details_tab(l_nss_details_tab.last).lc_count := l_nss_obj.get_string('LC_Count');
                    l_nss_details_tab(l_nss_details_tab.last).forcast_count := l_nss_obj.get_string('Forcast_Count');
                    l_nss_details_tab(l_nss_details_tab.last).nss_count := l_nss_obj.get_string('NSS_Count');
                    l_nss_details_tab(l_nss_details_tab.last).teacher_count := l_nss_obj.get_string('teacher_count');
                    l_nss_details_tab(l_nss_details_tab.last).status := l_nss_obj.get_string('status');
                    l_nss_details_tab(l_nss_details_tab.last).version := l_nss_obj.get_string('version');
                    l_nss_details_tab(l_nss_details_tab.last).comments := l_nss_obj.get_string('comments');
                    l_nss_details_tab(l_nss_details_tab.last).last_updated_by := l_last_updated_by;
                    l_nss_details_tab(l_nss_details_tab.last).created_by := l_created_by;
                END LOOP;

                FOR j IN 1..l_nss_details_tab.count LOOP
                    INSERT INTO xxnss_details (
                        nss_detail_id,
                        approvals_info_id,
                        s_no,
                        ay,
                        school,
                        category_info,
                        term_phase,
                        brand_info,
                        board_info,
                        grade,
                        sku_details,
                        sku_desc,
                        student_count,
                        lc_count,
                        forcast_count,
                        nss_count,
                        teacher_count,
                        created_by,
                        last_updated_by,
                        created_date,
                        last_updated_date
                    ) VALUES (
                        xxnss_nss_details_seq.NEXTVAL,
                        l_approvals_info_id,
                        l_nss_details_tab(j).s_no,
                        l_nss_details_tab(j).ay,
                        l_nss_details_tab(j).school,
                        l_nss_details_tab(j).category_info,
                        l_nss_details_tab(j).term_phase,
                        l_nss_details_tab(j).brand_info,
                        l_nss_details_tab(j).board_info,
                        l_nss_details_tab(j).grade,
                        l_nss_details_tab(j).sku_details,
                        l_nss_details_tab(j).sku_desc,
                        l_nss_details_tab(j).student_count,
                        l_nss_details_tab(j).lc_count,
                        l_nss_details_tab(j).forcast_count,
                        l_nss_details_tab(j).nss_count,
                        l_nss_details_tab(j).teacher_count,
                        l_created_by,
                        l_last_updated_by,
                        sysdate,
                        sysdate
                    );

                END LOOP;

                x_status := 'Imported Successfully';
                DELETE FROM xxnss_staging_tbl
                WHERE
                    batch_id = l_ret_batch_no;

            ELSE
                DELETE FROM xxnss_staging_tbl
                WHERE
                    batch_id = l_ret_batch_no;

                x_status := 'Error in Validation.Please check in error log for more details';
            END IF;

        ELSE
            x_status := 'Error in insert staging data';
        END IF;

        x_batch_id := l_ret_batch_no;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            x_status := sqlerrm || dbms_utility.format_error_backtrace;
            ROLLBACK;
    END xxnss_import_file;

    PROCEDURE xxnss_staging_import_file (
        p_data     IN BLOB,
        x_status   OUT VARCHAR2,
        x_batch_id OUT NUMBER
    ) IS

        TYPE t_nss_details_tab IS
            TABLE OF xxnss_details%rowtype;
        l_nss_details_tab   t_nss_details_tab := t_nss_details_tab();
        l_top_obj           json_object_t;
        l_nss_arr           json_array_t;
        l_nss_obj           json_object_t;
        l_file_name         VARCHAR2(500);
        l_file_type         VARCHAR2(300);
        l_created_by        VARCHAR2(500);
        l_last_updated_by   VARCHAR2(500);
        l_approvals_info_id NUMBER;
        l_batch_no          NUMBER;
    BEGIN
        l_batch_no := round(
                           dbms_random.value(
                                            100000,
                                            100000000000
                           ),
                           0
                      );
        l_top_obj := json_object_t(p_data);
        l_nss_arr := l_top_obj.get_array('nss_items');
        FOR i IN 0..l_nss_arr.get_size - 1 LOOP
            l_nss_obj := TREAT(l_nss_arr.get(i) AS json_object_t);
            l_nss_details_tab.extend;
            l_nss_details_tab(l_nss_details_tab.last).s_no := l_nss_obj.get_string('SNo');
            l_nss_details_tab(l_nss_details_tab.last).ay := l_nss_obj.get_string('AY');
            l_nss_details_tab(l_nss_details_tab.last).school := l_nss_obj.get_string('School');
            l_nss_details_tab(l_nss_details_tab.last).category_info := l_nss_obj.get_string('Category');
            l_nss_details_tab(l_nss_details_tab.last).term_phase := l_nss_obj.get_string('Term/Phase');
            l_nss_details_tab(l_nss_details_tab.last).brand_info := l_nss_obj.get_string('Brand');
            l_nss_details_tab(l_nss_details_tab.last).board_info := l_nss_obj.get_string('Board');
            l_nss_details_tab(l_nss_details_tab.last).grade := l_nss_obj.get_string('Grade');
            l_nss_details_tab(l_nss_details_tab.last).sku_details := l_nss_obj.get_string('SKU');
            l_nss_details_tab(l_nss_details_tab.last).student_count := l_nss_obj.get_string('Student Count');
            l_nss_details_tab(l_nss_details_tab.last).lc_count := l_nss_obj.get_string('LC_Count');
            l_nss_details_tab(l_nss_details_tab.last).forcast_count := l_nss_obj.get_string('Forcast_Count');
            l_nss_details_tab(l_nss_details_tab.last).nss_count := l_nss_obj.get_string('NSS_Count');
            l_nss_details_tab(l_nss_details_tab.last).teacher_count := l_nss_obj.get_string('teacher_count');
        END LOOP;

        FOR j IN 1..l_nss_details_tab.count LOOP
            INSERT INTO xxnss_staging_tbl (
                batch_id,
                s_no,
                ay,
                school,
                category_info,
                term_phase,
                brand_info,
                board_info,
                grade,
                sku_details,
                sku_desc,
                student_count,
                lc_count,
                forcast_count,
                nss_count,
                teacher_count
            ) VALUES (
                l_batch_no,
                l_nss_details_tab(j).s_no,
                l_nss_details_tab(j).ay,
                l_nss_details_tab(j).school,
                l_nss_details_tab(j).category_info,
                l_nss_details_tab(j).term_phase,
                l_nss_details_tab(j).brand_info,
                l_nss_details_tab(j).board_info,
                l_nss_details_tab(j).grade,
                l_nss_details_tab(j).sku_details,
                l_nss_details_tab(j).sku_desc,
                l_nss_details_tab(j).student_count,
                l_nss_details_tab(j).lc_count,
                l_nss_details_tab(j).forcast_count,
                l_nss_details_tab(j).nss_count,
                l_nss_details_tab(j).teacher_count
            );

        END LOOP;

        x_batch_id := l_batch_no;
        COMMIT;
        x_status := 'Y';
    EXCEPTION
        WHEN OTHERS THEN
            x_status := 'N';
           -- ROLLBACK;
    END xxnss_staging_import_file;

    PROCEDURE xxnss_validate_data (
        p_batch_no IN NUMBER,
        p_status   OUT VARCHAR2
    ) AS

        l_school_status   VARCHAR2(100);
        l_brand_status    VARCHAR2(100);
        l_board_status    VARCHAR2(100);
        l_grade_status    VARCHAR2(100);
        l_category_status VARCHAR2(100);
        l_term_status     VARCHAR2(100);
    BEGIN
        xxnss_pkg.xxnss_school_validate_nss_data(
                                                p_batch_no,
                                                l_school_status
        );
        xxnss_pkg.xxnss_grade_validate_nss_data(
                                               p_batch_no,
                                               l_grade_status
        );
        xxnss_pkg.xxnss_board_validate_nss_data(
                                               p_batch_no,
                                               l_board_status
        );
        xxnss_pkg.xxnss_brand_validate_nss_data(
                                               p_batch_no,
                                               l_brand_status
        );
        xxnss_pkg.xxnss_category_validate_data(
                                              p_batch_no,
                                              l_category_status
        );
        xxnss_pkg.xxnss_terms_phase_validate_nss_data(
                                                     p_batch_no,
                                                     l_term_status
        );
        IF l_term_status <> 'SUCCESS' OR l_category_status <> 'SUCCESS' OR l_grade_status <> 'SUCCESS' OR l_board_status <> 'SUCCESS'
        OR l_brand_status <> 'SUCCESS' OR l_school_status <> 'SUCCESS' THEN
            p_status := 'ERR';
        ELSE
            p_status := 'SUCCESS';
        END IF;

    END xxnss_validate_data;

    PROCEDURE xxnss_school_validate_nss_data (
        p_batch_no IN NUMBER,
        p_status   OUT VARCHAR2
    ) AS

        l_status      VARCHAR2(10);
        l_school_name VARCHAR2(300);
        l_cnt         NUMBER;
        l_s_no        NUMBER;
        CURSOR nss_data_list (
            batch_id NUMBER
        ) IS
        SELECT
            school,
            s_no
        FROM
            xxnss_staging_tbl
    
