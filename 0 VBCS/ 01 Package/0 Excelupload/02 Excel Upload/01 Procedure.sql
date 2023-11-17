create or replace PROCEDURE STAAR_UPLOAD_PRO (
							p_data IN BLOB,
                            p_batch_id OUT VARCHAR2,
                            p_code OUT VARCHAR2,
                            p_message OUT VARCHAR2
                        ) AS
CURSOR ldata 
is

SELECT
sphere,        
cylinder,      
sales_category,
customer,      
price,         
created_by     
FROM
JSON_TABLE ( p_data FORMAT JSON, '$.parts[*]'
    COLUMNS (
    sphere          VARCHAR2      PATH   '$.sphere',
    cylinder        VARCHAR2      PATH   '$.cylinder',      
    sales_category  VARCHAR2      PATH   '$.sales_category',
    customer        VARCHAR2      PATH   '$.customer',      
    price           VARCHAR2      PATH   '$.price',          
    created_by      VARCHAR2      PATH   '$.created_by'  
    )
);



-- Declare variables
   l_batch_id  NUMBER := BATCH_ID_S.NEXTVAL;
   l_count NUMBER := 0;
   p_err_msg varchar2(1500);
   p_err_code varchar2(30);

BEGIN
-- Insert data into STG
FOR i IN ldata
LOOP
--
INSERT INTO staar_sphere_src_data_tbl (
    sphere,
    cylinder,
    sales_category,
    customer,
    price,
    uploaded_date,
    batch_id,
    unique_id,
    creation_date,
    created_by,
    last_update_date,
    last_update_by
) VALUES (
    i.sphere,
    i.cylinder,
    i.sales_category,
    i.customer,
    i.price,
    sysdate,
    l_batch_id,
    unique_id.nextval,
    sysdate,
    i.created_by,
    sysdate,
    i.created_by
);

commit;

END LOOP;

    p_message := 'Success';
    p_code := 'S';
    p_batch_id := l_batch_id;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        -- Handle exceptions here...
    p_message := 'Error'||sqlerrm;
    p_code := 'E';
    p_batch_id := 0;
END STAAR_UPLOAD_PRO;
