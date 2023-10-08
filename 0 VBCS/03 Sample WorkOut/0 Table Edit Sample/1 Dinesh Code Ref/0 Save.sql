aa
create or replace PROCEDURE xx_save_delegation (
    p_data           IN BLOB,
    x_status         OUT VARCHAR2,
    x_status_message OUT VARCHAR2
) IS

--SELECT * FROM XX_DELEGATION

    CURSOR ldata IS
    SELECT
                approver,
                approver_level,
                created_by,
                created_date,
                case 
                    when LENGTH(delegate_start_date)=20 then to_date(substr(delegate_start_date, 1,10), 'RRRR-MM-DD')
                    when LENGTH(delegate_start_date)=10 then to_date(delegate_start_date, 'RRRR-MM-DD')
                    else to_date(delegate_start_date, 'RRRR-MM-DD')
                end as delegate_start_date,
                delegate_user_id,
                case 
                    when LENGTH(delgate_end_date)=20 then to_date(substr(delgate_end_date, 1,10), 'RRRR-MM-DD')
                    when LENGTH(delgate_end_date)=10 then to_date(delgate_end_date, 'RRRR-MM-DD')
                    else to_date(delgate_end_date, 'RRRR-MM-DD')
                end as delgate_end_date,
                case 
                    when LENGTH(end_date)=20 then to_date(substr(end_date, 1,10), 'RRRR-MM-DD')
                    when LENGTH(end_date)=10 then to_date(end_date, 'RRRR-MM-DD')
                    else to_date(end_date, 'RRRR-MM-DD')
                end as end_date,
                NVL(hierarchy_id, 0) as hierarchy_id,
                last_updated_by,
                last_updated_date,
                level_id,
                object_type,
                case 
                    when LENGTH(start_date)=20 then to_date(substr(start_date, 1,10), 'RRRR-MM-DD')
                    when LENGTH(start_date)=10 then to_date(start_date, 'RRRR-MM-DD')
                    else to_date(start_date, 'RRRR-MM-DD')
                end as start_date
    FROM
        JSON_TABLE ( p_data FORMAT JSON, '$.items[*]'
            COLUMNS (
                approver                VARCHAR2     PATH '$.approver',
                approver_level          NUMBER       PATH '$.approver_level',
                created_by              VARCHAR2     PATH '$.created_by',
                created_date            DATE         PATH '$.created_date',
                delegate_start_date     VARCHAR2     PATH '$.delegate_start_date',
                delegate_user_id        VARCHAR2     PATH '$.delegate_user_id',
                delgate_end_date        VARCHAR2     PATH '$.delgate_end_date',
                end_date                VARCHAR2     PATH '$.end_date',
                hierarchy_id            NUMBER       PATH '$.hierarchy_id',
                last_updated_by         VARCHAR2     PATH '$.last_updated_by',
                last_updated_date       DATE         PATH '$.last_updated_date',
                level_id                NUMBER       PATH '$.level_id',
                object_type             VARCHAR2     PATH '$.object_type',
                start_date              VARCHAR2     PATH '$.start_date'
            )
        );
        l_count NUMBER := 0;
--      x_status   VARCHAR2(60);
--      x_status_message VARCHAR2(240);

BEGIN
    FOR i IN ldata LOOP
        l_count := l_count + 1;
        --
        if(i.hierarchy_id !=0) then 
            update xx_delegation
            set 
            level_id=i.level_id,
            object_type=i.object_type, 
            approver=i.approver, 
            approver_level=i.approver_level, 
            start_date=i.start_date, 
            end_date=i.end_date, 
            delegate_start_date=i.delegate_start_date, 
            delgate_end_date=i.delgate_end_date, 
            delegate_user_id=i.delegate_user_id, 
--          created_by=i.created_by, 
--          created_date=i.last_updated_by, 
            last_updated_by=i.last_updated_by, 
            last_updated_date=i.last_updated_date
            where 
            hierarchy_id=i.hierarchy_id;
            commit;
        else
            INSERT INTO xx_delegation (
                hierarchy_id,
                level_id,
                object_type,
                approver,
                approver_level,
                start_date,
                end_date,
                delegate_start_date,
                delgate_end_date,
                delegate_user_id,
                created_by,
                last_updated_by,
                created_date,
                last_updated_date
            )VALUES (
                HIERARCHY_ID_S.nextval,
                i.level_id,
                i.object_type,
                i.approver,
                i.approver_level,
                i.start_date,
                i.end_date,
                i.delegate_start_date,
                i.delgate_end_date,
                i.delegate_user_id,
                i.created_by,
                i.last_updated_by,
                sysdate,
                sysdate
            );
            commit;
        end if;
    END LOOP;
    x_status := 'Y';
    x_status_message := 'Success';
EXCEPTION
    WHEN OTHERS THEN
        x_status := 'N';
        x_status_message := sqlerrm;
END xx_save_delegation;
