create or replace procedure xxpm_json(propertydtl IN clob, pout out VARCHAR2) 
IS
  po_obj        JSON_OBJECT_T;
  li_arr        JSON_ARRAY_T;
  li_item       JSON_ELEMENT_T;
  li_obj        JSON_OBJECT_T;
  unitPrice     VARCHAR2(240);
  quantity      VARCHAR2(240);
  totalPrice    VARCHAR2(240);
  totalQuantity VARCHAR2(240);
BEGIN
  li_arr := JSON_ARRAY_T.parse(propertydtl);
  
FOR i IN 0 .. li_arr.get_size - 1 
LOOP
DBMS_OUTPUT.PUT_LINE(i);
li_obj := JSON_OBJECT_T(li_arr.get(i));
    quantity := li_obj.get_String('PROPERTY_ID');
    unitPrice := li_obj.get_String('PROPERTY_NAME');
    DBMS_OUTPUT.PUT_LINE('PROPERTY_ID=>'||quantity);
    DBMS_OUTPUT.PUT_LINE('PROPERTY_NAME=>'||unitPrice);
NULL;
END LOOP;
  
  
    
--pout:=quantity;
END xxpm_json;
-----------------------------
SET SERVEROUTPUT ON;

DECLARE
    propertydtl   CLOB;
    pout          VARCHAR2(200);
BEGIN
    propertydtl := '[{
        "PROPERTY_ID": 1000400,
        "PROPERTY_NAME": "The Square",
        "PROPERTY_NAME_TL": null,
        "PROPERTY_NUMBER": "TSQ",
        "PROPERTY_SHORTCODE": "TSQ",
        "NO_OF_UNITS": 1750
  },
  {
        "PROPERTY_ID": 1000401,
        "PROPERTY_NAME": "Square",
        "PROPERTY_NAME_TL": null,
        "PROPERTY_NUMBER": "TSQ",
        "PROPERTY_SHORTCODE": "TSQ",
        "NO_OF_UNITS": 1750
  }]
  '
    ;
    xxpm_json(propertydtl => propertydtl, pout => pout);
    dbms_output.put_line('POUT = ' || pout);
END;
