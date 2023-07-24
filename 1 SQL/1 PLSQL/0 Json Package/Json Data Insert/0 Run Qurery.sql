SET SERVEROUTPUT ON;
DECLARE
  PROPERTYDTL VARCHAR2(32767);
  POUT VARCHAR2(200);
BEGIN
  PROPERTYDTL := 
'{
	"l_data":[
				{
					"PROPERTY_ID": "1000400",
					"PROPERTY_NAME": "The Square",
					"PROPERTY_NAME_TL": "",
					"PROPERTY_NUMBER": "DCT",
					"PROPERTY_SHORTCODE": "DCT",
					"NO_OF_UNITS": "173",
					"AREALINE": [
						{
							"AREA": "CHARGE",
							"UOM": "SQFT",
							"VALUE": "1"
						},
						{
							"AREA": "CHARGE",
							"UOM": "SQFT",
							"VALUE": "2"
						},
						{
							"AREA": "CHARGE",
							"UOM": "SQFT",
							"VALUE": "3"
						}
					]
				},
				{
					"PROPERTY_NAME": "The 2",
					"PROPERTY_NAME_TL": "2",
					"PROPERTY_NUMBER": "DCT2",
					"PROPERTY_SHORTCODE": "DCT2",
					"NO_OF_UNITS": "1732",
					"AREALINE": [
						{
							"AREA": "CHARGE2",
							"UOM": "SQFT",
							"VALUE": "1"
						},
						{
							"AREA": "CHARGE2",
							"UOM": "SQFT",
							"VALUE": "2"
						},
						{
							"AREA": "CHARGE",
							"UOM": "SQFT",
							"VALUE": "3"
						}
					]
				}
			]
}

';  

  XXPM_PROPERTY_JSON_PKG(
    PROPERTYDTL => PROPERTYDTL,
    POUT => POUT
  );
DBMS_OUTPUT.PUT_LINE('POUT = ' || POUT);
END;
