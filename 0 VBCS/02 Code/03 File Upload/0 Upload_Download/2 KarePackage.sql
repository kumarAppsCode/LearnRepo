CREATE OR REPLACE PACKAGE xxkare_pkg AS


    PROCEDURE xxkare_import_file (
         p_data             IN  BLOB,
--         p_ay               IN  VARCHAR2,
--         p_school           IN  VARCHAR2,
--         p_category_info    IN  VARCHAR2,
         x_status           OUT VARCHAR2
        ,x_batch_id         out number
    );

END xxkare_pkg;
/


CREATE OR REPLACE PACKAGE BODY xxkare_pkg AS

    PROCEDURE xxkare_import_file (
         p_data             IN  BLOB,
--         p_ay               IN  VARCHAR2,
--         p_school           IN  VARCHAR2,
--         p_category_info    IN  VARCHAR2,
         x_status           OUT VARCHAR2
        ,x_batch_id         OUT NUMBER
    ) IS


--SELECT * FROM XXKARE_INFO_V;
--
--SELECT * FROM XXKARE_HEADER_INFO;
--
--SELECT * FROM XXKARE_DETAILS;

CURSOR LDATA 
is

SELECT
    kare_detail_id,                
    ay             ,              
    school          ,             
    category_info    ,            
    sku_details       ,           
    sku_desc           ,          
    required_sz         ,          
    kare_stock_sz        ,         
    school_shipped_qty_sz ,        
    open_kare_po_sz        ,       
    planned_procurement_sz  ,      
    required_wz              ,     
    kare_stock_wz             ,    
    school_shipped_qty_wz      ,   
    open_kare_po_wz             ,  
    planned_procurement_wz       , 
    to_be_procured_wz             
FROM
    JSON_TABLE ( p_data FORMAT JSON, '$.parts[*]'
        COLUMNS (
         kare_detail_id               number     PATH '$.kare_detail_id'     
        ,ay                           varchar2 	PATH '$.ay'
        ,school                       varchar2   PATH '$.school'
        ,category_info                varchar2   PATH '$.category_info'
        ,sku_details                  varchar2   PATH '$.sku_details'
        ,sku_desc                     varchar2   PATH '$.sku_desc'
        ,required_sz                  number     PATH '$.required_sz'   
        ,kare_stock_sz                number     PATH '$.kare_stock_sz'   
        ,school_shipped_qty_sz        number     PATH '$.school_shipped_qty_sz'   
        ,open_kare_po_sz              number     PATH '$.open_kare_po_sz'   
        ,planned_procurement_sz       number     PATH '$.planned_procurement_sz'    
        ,required_wz                  number     PATH '$.required_wz'               
        ,kare_stock_wz                number     PATH '$.kare_stock_wz'             
        ,school_shipped_qty_wz        number     PATH '$.school_shipped_qty_wz'     
        ,open_kare_po_wz              number     PATH '$.open_kare_po_wz'           
        ,planned_procurement_wz       number     PATH '$.planned_procurement_wz'    
        ,to_be_procured_wz            number     PATH '$.to_be_procured_wz'
        )
    );


l_count number:=0;
l_batch_no          NUMBER;

BEGIN
--l_batch_no := round(dbms_random.value(100000,100000000000),0);

for i in LDATA 
loop
l_count:=l_count+1;

update XXKARE_DETAILS
set 
--  sku_details=i.sku_details,           
    sku_desc=i.sku_desc           ,          
    required_sz=i.required_sz         ,          
    kare_stock_sz=i.kare_stock_sz        ,         
    school_shipped_qty_sz=i.school_shipped_qty_sz ,        
    open_kare_po_sz=i.open_kare_po_sz        ,       
    planned_procurement_sz=i.planned_procurement_sz  ,      
    required_wz=i.required_wz              ,     
    kare_stock_wz=i.kare_stock_wz             ,    
    school_shipped_qty_wz=i.school_shipped_qty_wz      ,   
    open_kare_po_wz=i.open_kare_po_wz             ,  
    planned_procurement_wz=i.planned_procurement_wz       , 
    to_be_procured_wz=i.to_be_procured_wz             
where 
1=1
and upper(ay)=upper(i.ay)              
and upper(school)=upper(i.school)
and upper(category_info)=upper(i.category_info)
and upper(SKU_DETAILS)=upper(i.sku_details)
;
commit;



--null;
end loop;
        x_batch_id := 0;
        COMMIT;
        x_status := 'Y';

EXCEPTION
        WHEN OTHERS THEN
        x_status := 'N' ;
        x_batch_id:=0;
           -- ROLLBACK;
END xxkare_import_file;



END xxkare_pkg;
/
