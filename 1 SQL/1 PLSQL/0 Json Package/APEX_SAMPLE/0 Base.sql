SET SERVEROUTPUT ON
DECLARE
  l_json_text VARCHAR2(32767);
  l_count     PLS_INTEGER;
  l_members   WWV_FLOW_T_VARCHAR2;
  l_paths     APEX_T_VARCHAR2;
  l_exists    BOOLEAN;
BEGIN
  l_json_text := '{
	"department": {
		"department_number": 10,
		"department_name": "ACCOUNTING",
		"employees": [
			{
				"employee_number": 7782,
				"employee_name": "CLARK"
			},
			{
				"employee_number": 7839,
				"employee_name": "KING"
			},
			{
				"employee_number": 7934,
				"employee_name": "MILLER"
			}
		]
	},
	"metadata": {
		"published_date": "04-APR-2016",
		"publisher": "oracle-base.com"
	}
}';

  APEX_JSON.parse(l_json_text);
   
  DBMS_OUTPUT.put_line('----------------------------------------'); 
  DBMS_OUTPUT.put_line('Department Information (Basic path lookup)'); 
  DBMS_OUTPUT.put_line('Department Number : ' ||APEX_JSON.get_number(p_path => 'department.department_number')); 

  DBMS_OUTPUT.put_line('Department Name   : ' ||APEX_JSON.get_varchar2(p_path => 'department.department_name'));

  DBMS_OUTPUT.put_line('----------------------------------------'); 
  DBMS_OUTPUT.put_line('Employee Information (Loop through array)');

  l_count := APEX_JSON.get_count(p_path => 'department.employees');
  DBMS_OUTPUT.put_line('Employees Count   : ' || l_count);
  
  FOR i IN 1 .. l_count LOOP
    DBMS_OUTPUT.put_line('Employee Item Idx : ' || i); 

    DBMS_OUTPUT.put_line('Employee Number   : ' ||APEX_JSON.get_number(p_path => 'department.employees[%d].employee_number', p0 => i)); 

    DBMS_OUTPUT.put_line('Employee Name     : ' ||APEX_JSON.get_varchar2(p_path => 'department.employees[%d].employee_name', p0 => i)); 
  END LOOP;



  DBMS_OUTPUT.put_line('----------------------------------------'); 
  DBMS_OUTPUT.put_line('Check elements (members) below a path');
  
  l_members := APEX_JSON.get_members(p_path=>'department');
  DBMS_OUTPUT.put_line('Members Count     : ' || l_members.COUNT);

  FOR i IN 1 .. l_members.COUNT LOOP
    DBMS_OUTPUT.put_line('Member Item Idx   : ' || i); 
    DBMS_OUTPUT.put_line('Member Name       : ' || l_members(i)); 
  END LOOP;



  DBMS_OUTPUT.put_line('----------------------------------------'); 
  DBMS_OUTPUT.put_line('Search for matching elements in an array'); 
  l_paths := APEX_JSON.find_paths_like (p_return_path => 'department.employees[%]',
                                        p_subpath     => '.employee_name',
                                        p_value       => 'MILLER' );
 
  DBMS_OUTPUT.put_line('Matching Paths    : ' || l_paths.COUNT); 
  FOR i IN 1 .. l_paths.COUNT loop
    DBMS_OUTPUT.put_line('Employee Number   : ' ||
      APEX_JSON.get_number(p_path => l_paths(i)||'.employee_number')); 

    DBMS_OUTPUT.put_line('Employee Name     : ' ||
      APEX_JSON.get_varchar2(p_path => l_paths(i)||'.employee_name')); 
  END LOOP;
  


  DBMS_OUTPUT.put_line('----------------------------------------'); 
  DBMS_OUTPUT.put_line('Check if path exists'); 
  l_exists := APEX_JSON.does_exist (p_path => 'department.employees[%d].employee_name', p0 => 4);

  DBMS_OUTPUT.put('Employee 4 Exists : '); 
  IF l_exists THEN
    DBMS_OUTPUT.put_line('True');
  ELSE
    DBMS_OUTPUT.put_line('False'); 
  END IF;
  


  DBMS_OUTPUT.put_line('----------------------------------------'); 
  DBMS_OUTPUT.put_line('Metadata (Basic path lookup)'); 

  DBMS_OUTPUT.put_line('Department Number : ' ||
    APEX_JSON.get_date(p_path => 'metadata.published_date', p_format => 'DD-MON-YYYY')); 

  DBMS_OUTPUT.put_line('Department Name   : ' ||
    APEX_JSON.get_varchar2(p_path => 'metadata.publisher'));
  DBMS_OUTPUT.put_line('----------------------------------------'); 
END;
/
