CREATE OR REPLACE package XXPM_MOBILE_PKG
is

procedure GET_USER_AUTH_P(
                        P_USER_NAME   IN     VARCHAR2,
                        P_PASSWORD    IN     VARCHAR2,
                        P_RECORDSET      OUT SYS_REFCURSOR
                        );
--
PROCEDURE GET_PROPERTY_DTL (P_PROPERTY_NAME   IN     VARCHAR2,
                            P_RECORDSET        OUT SYS_REFCURSOR)
                            ;

end XXPM_MOBILE_PKG;
/


CREATE OR REPLACE PACKAGE BODY XXPM_MOBILE_PKG
IS

procedure GET_USER_AUTH_P(
                        P_USER_NAME   IN     VARCHAR2,
                        P_PASSWORD    IN     VARCHAR2,
                        P_RECORDSET      OUT SYS_REFCURSOR
)
as

L_COUNT NUMBER:=0;
L_CURSOR     SYS_REFCURSOR;

BEGIN
    --CHECK COUNT
    BEGIN
        SELECT COUNT(*) INTO L_COUNT 
        FROM XXSP_USER
        WHERE 
--          UPPER(USER_LOGIN)=UPPER('ABC001')
--          AND UPPER(USER_PASSWORD)=UPPER('Welcome123');
        UPPER(USER_LOGIN)=UPPER(P_USER_NAME)
        AND UPPER(USER_PASSWORD)=UPPER(P_PASSWORD);
    EXCEPTION WHEN OTHERS THEN 
    L_COUNT:=NULL;
    END;
--    
    IF(L_COUNT=1)THEN 
        OPEN L_CURSOR FOR
        SELECT 
        USER_ID, USER_LOGIN, USER_NAME, CREATED_BY
        FROM 
        XXSP_USER
        WHERE 
        UPPER(USER_LOGIN)=UPPER(P_USER_NAME)
        AND UPPER(USER_PASSWORD)=UPPER(P_PASSWORD);
    ELSE
        OPEN L_CURSOR FOR
        SELECT 
        -123 AS USER_ID, 
        -1 AS USER_LOGIN, 
        -1 AS USER_NAME, 
        -1 AS CREATED_BY
        FROM DUAL;
    END IF;
P_RECORDSET := L_CURSOR;
EXCEPTION
WHEN OTHERS
THEN
        OPEN L_CURSOR FOR
        SELECT 
        -2 AS USER_ID, 
        -1 AS USER_LOGIN, 
        -1 AS USER_NAME, 
        -1 AS CREATED_BY
        FROM DUAL;
P_RECORDSET := L_CURSOR;        
END GET_USER_AUTH_P;
--
PROCEDURE GET_PROPERTY_DTL (P_PROPERTY_NAME   IN     VARCHAR2,
                            P_RECORDSET        OUT SYS_REFCURSOR)
as
      L_CURSOR   SYS_REFCURSOR;
      L_COUNT    NUMBER;
   BEGIN
      IF P_PROPERTY_NAME IS NOT NULL
      THEN
         BEGIN
            OPEN L_CURSOR FOR
               SELECT 
                pro.PROPERTY_ID, pro.PROPERTY_NAME, pro.PROPERTY_NAME_TL, 
                pro.PROPERTY_NUMBER, pro.PROPERTY_SHORTCODE, pro.NO_OF_UNITS
--                ,cursor (SELECT pa.AREA_ID, pa.AREA, pa.UOM, pa.VALUE 
--                        FROM XXPM_PROPERTY_AREA pa
--                        where 
--                        pa.PROPERTY_ID is not null
--                        and pa.BUILD_ID is null
--                        and pa.UNIT_ID is null and 
--                        pro.PROPERTY_ID=pa.PROPERTY_ID
--                        ) as arealine
                FROM XXPM_PROPERTY_MASTER pro
                WHERE 
                NVL(UPPER(pro.PROPERTY_NAME), 'XXX') LIKE '%'||NVL(UPPER(P_PROPERTY_NAME), 'XXX')||'%';
--            DBMS_OUTPUT.PUT_LINE ('Get PROPERTY!!');
            P_RECORDSET := L_CURSOR;
         EXCEPTION
            WHEN OTHERS
            THEN
               OPEN L_CURSOR FOR
                  SELECT   
                    -1 AS PROPERTY_ID, -1 AS PROPERTY_NAME, -1 AS PROPERTY_NAME_TL, 
                    -1 AS PROPERTY_NUMBER, -1 AS PROPERTY_SHORTCODE, -1 AS NO_OF_UNITS
                    ,cursor (SELECT  -1 as AREA_ID, -1 as AREA, -1 as UOM, -1 as VALUE 
                        FROM dual) as arealine
                    FROM   DUAL
                   WHERE   1 = 1;

               P_RECORDSET := L_CURSOR;
               DBMS_OUTPUT.PUT_LINE ('Get PROPERTY!!');
         END;
      ELSE
         OPEN L_CURSOR FOR
            SELECT   
            -1 AS PROPERTY_ID, -1 AS PROPERTY_NAME, -1 AS PROPERTY_NAME_TL, 
            -1 AS PROPERTY_NUMBER, -1 AS PROPERTY_SHORTCODE, -1 AS NO_OF_UNITS
            ,cursor (SELECT  -1 as AREA_ID, -1 as AREA, -1 as UOM, -1 as VALUE 
            FROM dual) as arealine
            FROM   DUAL
            WHERE   1 = 1;
         DBMS_OUTPUT.PUT_LINE ('Get Shipment Ref Number Failed!!');
         P_RECORDSET := L_CURSOR;
      END IF;
END GET_PROPERTY_DTL;                            
                            

end XXPM_MOBILE_PKG;
/
