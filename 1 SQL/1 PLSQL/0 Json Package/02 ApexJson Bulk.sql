create or replace procedure APEX_JSON_PKG(propertydtl IN VARCHAR2, pout out VARCHAR2) 
IS

  l_json_text VARCHAR2(32767):='';
  l_count     PLS_INTEGER;
  l_members   WWV_FLOW_T_VARCHAR2;
  l_paths     APEX_T_VARCHAR2;
  l_exists    BOOLEAN;
BEGIN

  l_json_text:=propertydtl;

  APEX_JSON.parse(l_json_text);
   
  DBMS_OUTPUT.put_line('----------------------------------------'); 
  DBMS_OUTPUT.put_line('HEADER'); 
  DBMS_OUTPUT.put_line('PROPERTY_ID:' ||APEX_JSON.get_varchar2(p_path => 'PROPERTY_ID')); 
  DBMS_OUTPUT.put_line('Department Name: ' ||APEX_JSON.get_varchar2(p_path => 'PROPERTY_NAME'));
  DBMS_OUTPUT.put_line('----------------------------------------'); 
  if(APEX_JSON.get_varchar2(p_path => 'PROPERTY_ID')IS NOT NULL) then 
    DBMS_OUTPUT.put_line('IS NOT NULL');  
  else 
    DBMS_OUTPUT.put_line('IS NULL');  
  end if;

  DBMS_OUTPUT.put_line('----------------------------------------'); 
  DBMS_OUTPUT.put_line('LINE INFORMATION (Loop through array)');

  l_count := APEX_JSON.get_count(p_path => 'AREALINE');
  DBMS_OUTPUT.put_line('LINE Count   : ' || l_count);
  
  FOR i IN 1 .. l_count LOOP
    DBMS_OUTPUT.put_line('LINE LOOP : ' || i); 
    DBMS_OUTPUT.put_line('Area Id: ' ||
    APEX_JSON.get_varchar2(p_path => 'AREALINE[%d].AREA_ID', p0 => i)); 
    DBMS_OUTPUT.put_line('Area Value: ' ||
    APEX_JSON.get_varchar2(p_path => 'AREALINE[%d].AREA', p0 => i)); 
  END LOOP;
  DBMS_OUTPUT.put_line('----------------------------------------'); 

END APEX_JSON_PKG;
--------------------------------------
set SERVEROUTPUT ON;
DECLARE
  PROPERTYDTL VARCHAR2(32767);
  POUT VARCHAR2(200);
BEGIN
--    "PROPERTY_ID": "1000400",
  PROPERTYDTL := 
'{
   "PROPERTY_NAME": "The Square",
    "PROPERTY_NAME_TL": "",
    "PROPERTY_NUMBER": "DCT",
    "PROPERTY_SHORTCODE": "DCT",
    "NO_OF_UNITS": "173",
    "AREALINE": [
        {
            "AREA_ID": "8933",
            "AREA": "CHARGE",
            "UOM": "SQFT",
            "VALUE": "1"
        },
                {
            "AREA_ID": "8934",
            "AREA": "CHARGE",
            "UOM": "SQFT",
            "VALUE": "0"
        },
                {
            "AREA_ID": "8935",
            "AREA": "CHARGE",
            "UOM": "SQFT",
            "VALUE": "0"
        }
    ]
}
';

  APEX_JSON_PKG(
    PROPERTYDTL => PROPERTYDTL,
    POUT => POUT
  );
DBMS_OUTPUT.PUT_LINE('POUT = ' || POUT);
END;

